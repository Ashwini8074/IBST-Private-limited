



CREATE TABLE tenants (
    tenant_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


# users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Leads Table
CREATE TABLE leads (
    lead_id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES users(user_id),
    name VARCHAR(255) NOT NULL,
    details TEXT,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 4. Voice Logs Table
CREATE TABLE voice_logs (
    log_id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    lead_id INTEGER NOT NULL REFERENCES leads(lead_id),
    file_url VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration INTEGER, -- Duration in seconds
    transcript TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 1. Data Isolation
-- Data isolation ensures that each client (tenant) in a multi-tenant CRM/CLM system can only access their own data, preventing accidental or malicious data leaks between tenants.

-- Key Mechanisms
-- Tenant ID Foreign Key:
-- Every table that stores tenant-specific data (users, leads, voice logs) includes a tenant_id column. This explicitly associates each record with a tenant.

-- Row-Level Security (RLS):
-- Modern databases like PostgreSQL support RLS, which enforces access policies at the row level.

-- Example:
-- CREATE POLICY tenant_isolation ON leads
--   USING (tenant_id = current_setting('app.current_tenant')::INTEGER);
-- The application sets app.current_tenant for each session, and the database ensures users only see their own data.

-- 2. Log Security
-- Log security refers to protecting sensitive voice log data from unauthorized access, tampering, or leaks.


-- Access Control:
-- Each voice log is tagged with a tenant_id.
-- Only users with matching tenant_id can access or download the log.
-- Enforced via RLS and application logic.

-- Secure Storage:
-- Voice logs are stored in secure, access-controlled locations (e.g., encrypted S3 buckets or file systems).
-- Each tenant may have a separate storage path or bucket to further isolate access.

-- Encryption:
-- Voice log files are encrypted at rest and in transit.
-- Database connections and file transfers use TLS/SSL.

-- Audit Logging:
-- All access to voice logs is logged for audit and compliance.
-- Logs include timestamp, user, action, and resource accessed.

-- Immutable Records:
-- Voice log metadata (who, when, which lead) is immutable to prevent tampering.
-- Optionally, use append-only storage or WORM (Write Once, Read Many) for compliance.

-- Least Privilege:
-- Only authorized users (e.g., sales reps, managers) can access logs.
-- Roles and permissions are strictly enforced.

