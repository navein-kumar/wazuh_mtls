```
# Option 1: Enforce all path/folder  mtls

ssl_client_certificate /data/ca.pem;
ssl_verify_client on;
```

```
# option 2: exclude fr webhooks 
ssl_verify_client optional;
ssl_client_certificate /data/ca.pem;

# Exclude all webhooks from mTLS
location /webhook/ {
    proxy_pass http://n8n:5678;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# Everything else requires valid certificate
location / {
    if ($ssl_client_verify != "SUCCESS") {
        return 495;
    }
    proxy_pass http://n8n:5678;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```
