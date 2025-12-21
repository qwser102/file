### Preparation

Prepare the follow resource:

1. Performance test tools image(stability.tar.gz), push it to performance test server(Which should install docker).

2. Prepare the project `test` and namespace `test-ns1`.

3. Deployment the test service（nginx for example） in namespace `test-ns1`, and create a service and ingress rule for test service. For example: 

   `deployment_name`: nginx

   `svc`: nginx

   `ingress_rule`: nginx-demo.demo.com

```shell
# login to the performance test server
mkdir -p /root/performance/{login,deployment,ingress}
mkdir -p /root/performance/result/{login,deployment,ingress}
docker load -i stability.tar.gz
```

### Login performance test

Prepare the `envfile`

```shell
# cat /root/performance/login/envfile
JMETER_JMX_NAME=/performance/testcases/TestLogin/login.jmx
REPORT_DIR=/home/data/result
API_IP=192.168.176.48
API_PORT=443
API_TYPE=https
RUN_TIME=600
RUN_TEST_TIME=1
ACCOUNT=admin
PASSWORD=1qaz@WSX
THREAD_NUM=100
RAMP_UP_PERIOD=1
RECIPIENTS=admin@alauda.io
EMAIL_TITLE=staging_100threads_login_performance
```

Run the follow command:

```shell
cd /root/performance/login/
docker run -d --rm --env-file=envfile --net=host -v /root/performance/result/login:/home/data  registry.alauda.cn:60070/automation/stability:release-4.2
```

Wait for the test finished, and the test result will be saved in /root/performance/result/login.

### Deployment performance test

Prepare the `envfile`

```shell
# cat /root/performance/deployment/envfile
JMETER_JMX_NAME=/performance/testcases/TestACP2.10/post_put_delete_deployment.jmx
REPORT_DIR=/home/data/result
API_IP=192.168.176.48
API_PORT=443
API_TYPE=https
AUTH=local
IMAGE=192.168.176.48/3rdparty/nginx:v1
RUN_TIME=300
RUN_TEST_TIME=1
ACCOUNT=admin
PASSWORD=1qaz@WSX
THREAD_NUM=50
RAMP_UP_PERIOD=1
REGION_NAME=region1
PRO_NAME=test
NS_NAME=test-ns1
APP_NAME=test-00001
DEPLOY_NAME=test-00001
CM_NAME=configmap-00001
SVC_NAME=test-00001
INGRESS_NAME=ingress-00001
SLEEP=30
toleration_key=fakenode
NODE_NAME=master01
RECIPIENTS=pengjia@alauda.io
EMAIL_TITLE=staging_acp_api_200threads_performance
EMAIL_ATTACH=false
PAUSE_TIME=1
SMTP_USERNAME=jia18513519889@163.com
SMTP_PASSWORD=jia123
EMAIL_FROM=jia18513519889@163.com
SMTP_HOST=smtp.163.com
SMTP_PORT=465
SMTP_SSL=True
L3_THREAD_NUM=50
```

Run the follow command:

```shell
cd /root/performance/deployment/
docker run -d --rm --env-file=envfile --net=host -v /root/performance/result/deployment:/home/data  registry.alauda.cn:60070/automation/stability:release-4.2
```

Wait for the test finished, and the test result will be saved in /root/performance/result/deployment.

### Ingress performance test

Prepare the `envfile`

```shell
# cat /root/performance/ingress/envfile
JMETER_JMX_NAME=/performance/testcases/TestACP2.10/visit_app.jmx
REPORT_DIR=/home/data/result
APP_URL=http://nginx-demo.demo.com
APP_DOMAIN=nginx-demo.demo.com
THREAD_NUM=500
RUN_TIME=600
```

Run the follow command:

```shell
cd /root/performance/ingress/
docker run -d --rm --env-file=envfile --net=host -v /root/performance/result/ingress:/home/data  registry.alauda.cn:60070/automation/stability:release-4.2
```

Wait for the test finished, and the test result will be saved in /root/performance/result/deployment.

