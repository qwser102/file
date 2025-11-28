def get_token(idp_name="local", username=settings.USERNAME, password=settings.PASSWORD,
              first_login=True, api_url="", test_login=False):
    logger.info(f"get_token called with parameters: idp_name={idp_name}, username={username}, "
                f"first_login={first_login}, api_url={api_url}, test_login={test_login}, "
                f"settings.TOKEN={settings.TOKEN}, environ.TOKEN={os.environ.get('TOKEN')}")
    if settings.TOKEN and username == settings.USERNAME and not test_login:
        return (
            "",
            "Bearer {}".format(settings.TOKEN),
            "Bearer {}".format(settings.TOKEN),
        )
    api_url = settings.API_URL if not api_url else api_url
    logger.info(f"URL:{api_url},username: {username},password:{password},idp: {idp_name}")
    url = api_url + "/console-platform/api/v1/token/login"
    urllib3.disable_warnings()
    r = requests.get(url, verify=False, timeout=15, proxies=proxy)
    logger.info(f"Response: {r.text}")
    auth_url = r.json()["auth_url"]
    params = {
        "access_type": dict(parse_qsl(urlparse(auth_url).query)).get("access_type"),
        "client_id": dict(parse_qsl(urlparse(auth_url).query)).get("client_id"),
        "nonce": dict(parse_qsl(urlparse(auth_url).query)).get("nonce"),
        "redirect_uri": f"{api_url}/console-platform",
        "response_type": dict(parse_qsl(urlparse(auth_url).query)).get("response_type"),
        "scope": dict(parse_qsl(urlparse(auth_url).query)).get("scope"),
        "state": dict(parse_qsl(urlparse(auth_url).query)).get("state"),
    }
    auth_url = "{}/dex/api/v1/authorize".format(api_url)
    logger.info(f"auth url :{auth_url}, params:{params}")
    r = requests.get(auth_url, verify=False, proxies=proxy, params=params)
    logger.info(f"Get response body: {r.text}")
    req = r.json()["req"]
    url = "{}/dex/api/v1/authorize/{}?req={}".format(api_url, idp_name, req)
    # generate connectorID
    pwd = encrypt(password)
    data = {"account": str(username), "password": pwd}
    response = requests.post(url, json=data, verify=False, timeout=10, proxies=proxy)
    cookie = response.cookies.get_dict()
    logger.info(f"cookie:{response.cookies.get_dict()}")
    logger.info(f"response:{response.json()}")
    if (
        response.status_code == 500
        and response.json()["reason"] == "FirstLoginPasswordUpdate"
        and first_login
    ):
        pwd_url = api_url + "/dex/api/v1/password?req=" + req
        new_passwd = "new" + password
        for passwords in [[password, new_passwd], [new_passwd, password]]:
            data = {
                "old_password": encrypt(passwords[0]),
                "password": encrypt(passwords[1]),
            }
            sleep(5)
            ret = requests.put(
                pwd_url, json=data, verify=False, timeout=10, proxies=proxy
            )
            assert ret.status_code == 200, "update local user password failed，response result：{}".format(ret.text)
        return get_token(username=username, password=password)
    # content = response.history[1].text
    assert response.status_code == 200, f"login failed:{response.text}"
    logger.info("response login information:{}".format(response.text))
    redirect_url = response.json()["redirect_url"]
    logger.info(f"redirect url: {redirect_url}")

    code = dict(parse_qsl(urlparse(redirect_url).query)).get("code")
    state = dict(parse_qsl(urlparse(redirect_url).query)).get("state")
    url = f"{api_url}/console-platform/api/v1/token/callback"
    params = {"code": code, "state": state}
    logger.info(f"request url: {url}")
    logger.info(f"request params: {params}")
    r = requests.get(url, verify=False, proxies=proxy, params=params)
    ret = r.json()
    logger.debug("get token result:{}".format(ret))
    token = ret["id_token"]
    token_type = ret["token_type"]
    access_token = ret["access_token"]
    # the valve to refresh token
    refresh_token = ret["refresh_token"]
    # will expire token
    auth = "{} {}".format(token_type.capitalize(), token)
    # never expire token
    forver_auth = "{} {}".format(token_type.capitalize(), access_token)
    # expire time
    expiration_time = to_timestamp(ret["expire_at"])
    logger.info("*****Get token result*****")
    logger.info(f"token:{auth}, cookie:{cookie}, expiration_time:{expiration_time}, refresh_token:{refresh_token}, forver_auth:{forver_auth}")
    return auth, cookie, expiration_time, refresh_token, forver_auth
