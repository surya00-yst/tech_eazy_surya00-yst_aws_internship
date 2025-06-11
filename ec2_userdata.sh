#!/bin/bash
yum install -y awscli

cat > /opt/upload-logs.sh << 'EOC'
#!/bin/bash
set -e

if [[ -z "$BUCKET" ]]; then
  echo "ERROR: BUCKET environment variable not set" >&2
  exit 1
fi

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
TARGET_PREFIX="ec2-logs/${INSTANCE_ID}/${TIMESTAMP}"

aws s3 cp /var/log/cloud-init.log s3://$BUCKET/$TARGET_PREFIX/ || true
aws s3 cp /var/log/custom-app.log s3://$BUCKET/app/logs/${INSTANCE_ID}_${TIMESTAMP}.log || true
EOC

chmod +x /opt/upload-logs.sh

cat > /etc/systemd/system/upload-logs.service << 'EOC'
[Unit]
Description=Upload logs to S3 on shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
Environment=BUCKET=${bucket_name}
ExecStart=/usr/bin/true
ExecStop=/opt/upload-logs.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOC

systemctl daemon-reload
systemctl enable upload-logs.service
