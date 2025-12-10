```
# Option 1: Enforce all path/folder  mtls

ssl_client_certificate /data/ca.pem;
ssl_verify_client on;
```

```
# option 2: exclude fr webhooks 
ssl_verify_client optional;
ssl_client_certificate /data/ca.pem;

# Custom error page
error_page 400 @mtls_error;

location @mtls_error {
    return 400 '{"error":"Certificate Required","message":"Contact SOC team for access","email":"soc@codesecuresolutions.com"}';
    add_header Content-Type application/json;
}

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
        return 400;
    }
    proxy_pass http://n8n:5678;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```
