# Auto-FreeCF

Cloudflare Workers AI account automation via Google Workspace SSO.

## ⚠️ IMPORTANT: Google Workspace Required

This tool **requires** a Google Workspace account with domain-wide delegation enabled. It will create users in your Google Workspace domain, then attempt to link them to Cloudflare accounts.

**Why Google Workspace?**
- Cloudflare does not expose a public API for account creation
- Google Workspace provides programmatic user creation via Admin SDK
- Users created in Google Workspace can be used for Cloudflare SSO signup

## Prerequisites

1. **Google Workspace account** with:
   - Admin access to create users
   - Domain-wide delegation enabled for service account
   - Custom domain (e.g., `yourcompany.com`)

2. **Google Cloud Service Account** with:
   - Admin SDK API enabled
   - Domain-wide delegation configured
   - Scopes: `admin.directory.user`

3. **Python 3.10+**

## Setup

### 1. Create Google Cloud Service Account

```bash
# Go to Google Cloud Console
# https://console.cloud.google.com/iam-admin/serviceaccounts

# Create service account
# Download JSON key file
# Enable "Admin SDK API"
```

### 2. Enable Domain-Wide Delegation

```bash
# Go to Google Workspace Admin Console
# https://admin.google.com/ac/owl/domainwidedelegation

# Add service account client ID
# Add scopes:
#   https://www.googleapis.com/auth/admin.directory.user
#   https://www.googleapis.com/auth/admin.directory.user.readonly
```

### 3. Install Dependencies

```bash
cd /root/cf-account-bot
python3 -m venv venv
venv/bin/pip install -r requirements.txt
```

## Usage

### Create Google Workspace Users

```bash
./run.sh \
  --service-account /path/to/service-account.json \
  --delegated-email admin@yourcompany.com \
  --domain yourcompany.com \
  --count 5
```

This will:
1. Create 5 Google Workspace users (e.g., `abc123@yourcompany.com`)
2. Save credentials to `accounts.json`
3. Print instructions for manual CF account creation

### Extract Cloudflare Account IDs

After manually creating CF accounts with the Google Workspace emails:

```bash
# Create tokens.txt with one CF API token per line
echo "YOUR_CF_TOKEN_1" > tokens.txt
echo "YOUR_CF_TOKEN_2" >> tokens.txt

# Extract Account IDs and test Workers AI
./run.sh --token-file tokens.txt
```

Output:
- `exports/workers_ai_accounts.json`
- `exports/workers_ai_accounts.csv`

## Workflow

### Automated Part
1. ✅ Create Google Workspace users via Admin SDK
2. ✅ Save credentials to JSON
3. ✅ Extract CF Account IDs from existing tokens
4. ✅ Test Workers AI access

### Manual Part (Required)
1. ⚠️ Go to https://dash.cloudflare.com/sign-up
2. ⚠️ Click "Sign up with Google"
3. ⚠️ Login with Google Workspace email
4. ⚠️ Create Workers AI API token
5. ⚠️ Add token to `tokens.txt`

## Why Manual CF Creation?

Cloudflare's signup endpoint (`dash.cloudflare.com/sign-up`) is protected by:
- Managed Challenge (blocks VPS/datacenter IPs)
- No public API for account creation
- Session-based authentication required

Even with Google Workspace automation, the final CF account creation step requires browser interaction from a residential IP.

## Output Format

### accounts.json (Google Workspace users)
```json
[
  {
    "email": "abc123@yourcompany.com",
    "password": "RandomPassword123!",
    "google_user_id": "1234567890",
    "account_id": null,
    "api_token": null,
    "created_at": "2025-01-15 10:30:00",
    "status": "google_workspace_created"
  }
]
```

### exports/workers_ai_accounts.json (CF accounts)
```json
[
  {
    "email": "abc123@yourcompany.com",
    "account_id": "abc123def456",
    "account_name": "My Account",
    "api_token": "YOUR_CF_TOKEN",
    "workers_ai_ok": true,
    "workers_ai_error": null
  }
]
```

## Security Notes

- **Never commit** `service-account.json` or `tokens.txt` to git
- **Rotate** service account keys regularly
- **Limit** service account scopes to minimum required
- **Monitor** Google Workspace user creation logs
- **Delete** unused Google Workspace users

## Troubleshooting

### "Domain-wide delegation not enabled"
- Go to Google Workspace Admin Console
- Enable domain-wide delegation for service account
- Wait 5-10 minutes for propagation

### "Insufficient permissions"
- Ensure delegated email has admin privileges
- Check service account has correct scopes
- Verify Admin SDK API is enabled

### "User already exists"
- Google Workspace user already exists in domain
- Use different username or delete existing user

### "CF account creation failed"
- Expected: CF requires manual browser creation
- Follow manual steps in workflow section

## License

MIT
