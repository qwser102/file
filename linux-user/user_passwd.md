```
cat /etc/passwd

/bin/bash//bin/sh//usr/bin/zsh    # Have login foundation (password login depends on other rules)
/sbin/nologin//usr/sbin/nologin   # Prohibit logging into Shell
/bin/false                        # Empty Shell (exit immediately)
/*                                # Abnormal configuration, usually login prohibited

# Step1
# Filter login shell for interactive users (with login basics only)
grep -vE "/nologin|/false" /etc/passwd

# Step2
# Check if the password field in/etc/shadow is valid
cat /etc/shadow
#Example 1: Password is valid (password login is allowed, SSH permission is required)
testuser:$6$abc123$xyz789:19500:0:99999:7:::
#Example 2: Password locked (unable to log in with password)
testuser:*:19500:0:99999:7:::

#Step3
# Check SSH configuration: whether password login is allowed
sudo sshd -T | grep -E "passwordauthentication|challengeresponseauthentication"
#Key values:
#PasswordAuthentication no → Disable all password login (even if the password is valid)
#PasswordAuthentication yes → Allow password login (password field must be valid)

# Step4
# Check if the specified user is locked
passwd -S testuser
#Example output:
#Not locked (P=password valid, PS=password setting): testuser P 01/04/226 0 99999 7-1
#Locked (L=Locked): testuser L 01/04/226 0 99999 7-1
```
