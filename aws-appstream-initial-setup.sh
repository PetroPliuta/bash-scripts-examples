#!/bin/sh

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Create user account for automation, logon using password not configured
echo "Creating as2-automation user."
sudo useradd -m -d /home/as2-automation -s /bin/bash as2-automation

# Allow automation account to elevate to sudo without prompt
echo "Granting as2-user sudo rights."
echo "as2-automation      ALL=(ALL)       NOPASSWD: ALL" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/as2-automation-users')

# Create key pair for remote ssh connection
echo "Generating SSH key."
ssh-keygen -m PEM -f /tmp/automate -q -N ""

# Move private key to AppStream temporary files location for easy download
mv /tmp/automate /home/ImageBuilderAdmin/MyFiles/TemporaryFiles/as2-automate.pem

# Move public key into automation account and configure to allow ssh connection
echo "Configuring SSH key for as2-automation user remote access."
sudo mkdir /home/as2-automation/.ssh
sudo mv /tmp/automate.pub /home/as2-automation/.ssh/authorized_keys
sudo chown as2-automation:as2-automation /home/as2-automation/.ssh
sudo chown as2-automation:as2-automation /home/as2-automation/.ssh/authorized_keys
