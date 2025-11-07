# Admin Endpoints

This document describes admin endpoints for managing the Tote Bag backend.

## Sync SuperTokens User to Database

**Endpoint**: `POST /api/v1/admin/sync-user/:userId`

**Purpose**: Sync a user from SuperTokens to the application database.

### When to Use

This endpoint is useful when:
1. A user was created directly in the SuperTokens dashboard (not through signup API)
2. The signup hook failed to create the user in the database
3. You need to manually sync existing SuperTokens users

### Usage

```bash
curl -X POST http://localhost:3333/api/v1/admin/sync-user/{SUPERTOKENS_USER_ID}
```

### Example

```bash
# Sync user with ID 62f9de51-f029-4563-a4fd-9a289a5a88bd
curl -X POST http://localhost:3333/api/v1/admin/sync-user/62f9de51-f029-4563-a4fd-9a289a5a88bd
```

### Response

**Success (200)**:
```json
{
  "status": "success",
  "message": "User synced successfully",
  "data": {
    "user": {
      "id": "414b96b3-93bc-4540-b988-b0c14003a248",
      "email": "user@example.com",
      "displayName": "User Name",
      "supertokensUserId": "62f9de51-f029-4563-a4fd-9a289a5a88bd",
      "isActive": true,
      "createdAt": "2025-11-07T18:46:41.382Z",
      "updatedAt": "2025-11-07T18:46:41.382Z"
    }
  }
}
```

**User Already Exists (200)**:
```json
{
  "status": "success",
  "message": "User already exists in database",
  "data": { "user": {...} }
}
```

**User Not Found in SuperTokens (404)**:
```json
{
  "status": "error",
  "message": "User not found in SuperTokens"
}
```

**No Email Found (400)**:
```json
{
  "status": "error",
  "message": "No email found for this user"
}
```

### How It Works

1. Checks if user already exists in the database
2. Fetches user info from SuperTokens using `supertokens.getUser()`
3. Extracts email from the user's login methods
4. Creates a new user record in the application database
5. Returns the created/existing user

### Important Notes

- **No Authentication**: This endpoint currently has no authentication. In production, you should add proper authentication/authorization.
- **Idempotent**: Safe to call multiple times - returns existing user if already in database
- **Email Required**: User must have an email associated with their SuperTokens account
- **Display Name**: If not provided, uses email prefix as display name

### Security Recommendations

For production use, you should:
1. Add authentication (e.g., API key, admin role check)
2. Add rate limiting
3. Add audit logging
4. Consider moving to a separate admin API service

### Related

- User signup hook: `backend/src/hooks/supertokens.js`
- User service: `backend/src/services/UserService.js`
- SuperTokens config: `backend/src/config/supertokens.js`
