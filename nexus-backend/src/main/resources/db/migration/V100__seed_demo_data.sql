-- =========================================================
-- V100__seed_demo_data.sql
-- Nexus Database Migration: Demo Seed Data (PRD §20)
-- =========================================================

-- 1. Demo Organization
INSERT INTO organizations (id, name, created_at)
VALUES ('11111111-1111-1111-1111-111111111111', 'Acme Global Operations', NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- 2. Demo Users (Password: Password123!)
-- BCrypt hash for Password123!: $2a$10$eACCYoNOHEqgkZddBx29Oeetnn6ux.kL3s8.4vK1/a7GZ/Qy97iYq
INSERT INTO users (id, organization_id, name, email, password_hash, status, created_at)
VALUES 
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Sarah Connor (Requester)', 'requester@nexus.com', '$2a$10$eACCYoNOHEqgkZddBx29Oeetnn6ux.kL3s8.4vK1/a7GZ/Qy97iYq', 'ACTIVE', NOW() - INTERVAL '25 days'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'Elena Vance (Operator)', 'operator@nexus.com', '$2a$10$eACCYoNOHEqgkZddBx29Oeetnn6ux.kL3s8.4vK1/a7GZ/Qy97iYq', 'ACTIVE', NOW() - INTERVAL '25 days'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 'Marcus Brody (Team Lead)', 'lead@nexus.com', '$2a$10$eACCYoNOHEqgkZddBx29Oeetnn6ux.kL3s8.4vK1/a7GZ/Qy97iYq', 'ACTIVE', NOW() - INTERVAL '25 days'),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'Rachel Sterling (Problem Lead)', 'problem.manager@nexus.com', '$2a$10$eACCYoNOHEqgkZddBx29Oeetnn6ux.kL3s8.4vK1/a7GZ/Qy97iYq', 'ACTIVE', NOW() - INTERVAL '25 days'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', 'Gaurav Kadam (Admin)', 'admin@nexus.com', '$2a$10$eACCYoNOHEqgkZddBx29Oeetnn6ux.kL3s8.4vK1/a7GZ/Qy97iYq', 'ACTIVE', NOW() - INTERVAL '25 days')
ON CONFLICT (email) DO NOTHING;

-- 3. Assign User Roles
INSERT INTO user_roles (user_id, role_id)
SELECT 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', id FROM roles WHERE name = 'REQUESTER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', id FROM roles WHERE name = 'OPERATOR'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT 'cccccccc-cccc-cccc-cccc-cccccccccccc', id FROM roles WHERE name = 'TEAM_LEAD'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT 'dddddddd-dddd-dddd-dddd-dddddddddddd', id FROM roles WHERE name = 'MANAGER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', id FROM roles WHERE name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- 4. Teams
INSERT INTO teams (id, organization_id, name, lead_user_id, created_at)
VALUES 
    ('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 'Tier 1 Triage & Dispatch', 'cccccccc-cccc-cccc-cccc-cccccccccccc', NOW() - INTERVAL '20 days'),
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Core SRE & Cloud DevOps', 'cccccccc-cccc-cccc-cccc-cccccccccccc', NOW() - INTERVAL '20 days'),
    ('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', 'SecOps & Identity Access', 'cccccccc-cccc-cccc-cccc-cccccccccccc', NOW() - INTERVAL '20 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO team_members (team_id, user_id)
VALUES 
    ('22222222-2222-2222-2222-222222222221', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
    ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')
ON CONFLICT DO NOTHING;

-- 5. Categories
INSERT INTO categories (id, organization_id, name, default_team_id, created_at)
VALUES 
    ('33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111111', 'Network & VPN Infrastructure', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '20 days'),
    ('33333333-3333-3333-3333-333333333332', '11111111-1111-1111-1111-111111111111', 'Software Access & Licensing', '22222222-2222-2222-2222-222222222221', NOW() - INTERVAL '20 days'),
    ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Hardware & IT Workstations', '22222222-2222-2222-2222-222222222221', NOW() - INTERVAL '20 days'),
    ('33333333-3333-3333-3333-333333333334', '11111111-1111-1111-1111-111111111111', 'Cloud Infrastructure & SRE', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '20 days')
ON CONFLICT (id) DO NOTHING;

-- 6. SLA Policies
INSERT INTO sla_policies (id, organization_id, category_id, priority, response_time_minutes, resolution_time_minutes, created_at, updated_at)
VALUES 
    ('44444444-4444-4444-4444-444444444441', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333334', 'URGENT', 15, 60, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('44444444-4444-4444-4444-444444444442', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333331', 'HIGH', 60, 240, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('44444444-4444-4444-4444-444444444443', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333332', 'MEDIUM', 240, 1440, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'LOW', 480, 2880, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days')
ON CONFLICT (id) DO NOTHING;

-- 7. Escalation Rules
INSERT INTO escalation_rules (id, organization_id, name, condition_type, condition_config, escalation_level, category_id, is_active, created_by, created_at, updated_at)
VALUES 
    ('55555555-5555-5555-5555-555555555551', '11111111-1111-1111-1111-111111111111', 'P1 Breach Fast-Track to Lead', 'SLA_APPROACHING', '{"thresholdMinutes": 15}', 'TEAM_LEAD', '33333333-3333-3333-3333-333333333334', TRUE, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
    ('55555555-5555-5555-5555-555555555552', '11111111-1111-1111-1111-111111111111', 'Major Outage Manager Escalation', 'HIGH_IMPACT_INCIDENT', '{"severity": "CRITICAL"}', 'MANAGER', NULL, TRUE, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days')
ON CONFLICT (id) DO NOTHING;

-- 8. Realistic Cases
INSERT INTO cases (id, case_number, title, description, category_id, severity, priority, status, requester_id, assigned_team_id, assigned_user_id, created_at, updated_at)
VALUES 
    ('66666666-6666-6666-6666-666666666661', 'NEX-2026-0104', 'Authentication Gateway Timeout during SSO federation', 'Upstream IDP response latency spiked to 4.8s. 12 enterprise tenants encountering HTTP 504 gateway response errors.', '33333333-3333-3333-3333-333333333334', 'CRITICAL', 'URGENT', 'INVESTIGATING', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '15 minutes'),
    ('66666666-6666-6666-6666-666666666662', 'NEX-2026-0087', 'Kubernetes Pod OOMKilled in production US-East cluster', 'Memory limit exceeded on payment-processing service pods. Pod restart loop causing 0.5% transaction dropped rate.', '33333333-3333-3333-3333-333333333334', 'CRITICAL', 'URGENT', 'INVESTIGATING', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '5 hours', NOW() - INTERVAL '1 hour'),
    ('66666666-6666-6666-6666-666666666663', 'NEX-2026-0042', 'VPN Connection drops intermittently on MacBook Sequoia', 'Experiencing continuous connection reset when connecting to US-East Gateway over WireGuard protocol.', '33333333-3333-3333-3333-333333333331', 'HIGH', 'HIGH', 'WAITING_FOR_INFO', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 hours'),
    ('66666666-6666-6666-6666-666666666664', 'NEX-2026-0038', 'Figma Enterprise license invitation expired', 'Need license renewal for new design sprint starting Monday morning.', '33333333-3333-3333-3333-333333333332', 'MEDIUM', 'MEDIUM', 'ASSIGNED', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222221', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '2 days', NOW() - INTERVAL '4 hours'),
    ('66666666-6666-6666-6666-666666666665', 'NEX-2026-0021', 'MacBook Pro battery service alert', 'Battery health dropped below 70%, diagnostic tool recommends hardware replacement.', '33333333-3333-3333-3333-333333333333', 'LOW', 'LOW', 'CLOSED', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222221', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day'),
    ('66666666-6666-6666-6666-666666666666', 'NEX-2026-0115', 'Database connection pool exhausted on Payment Gateway', 'HikariCP connection pool hit max 50 active connections during flash sale checkout spike.', '33333333-3333-3333-3333-333333333334', 'CRITICAL', 'URGENT', 'REPORTED', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', NULL, NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '20 minutes')
ON CONFLICT (id) DO NOTHING;

-- 9. Case SLA Records
INSERT INTO case_sla (id, case_id, sla_policy_id, response_deadline, resolution_deadline, status, responded_at, created_at, updated_at)
VALUES 
    ('77777777-7777-7777-7777-777777777771', '66666666-6666-6666-6666-666666666661', '44444444-4444-4444-4444-444444444441', NOW() - INTERVAL '2 hours 45 minutes', NOW() + INTERVAL '45 minutes', 'ON_TRACK', NOW() - INTERVAL '2 hours 50 minutes', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '15 minutes'),
    ('77777777-7777-7777-7777-777777777772', '66666666-6666-6666-6666-666666666662', '44444444-4444-4444-4444-444444444441', NOW() - INTERVAL '4 hours 45 minutes', NOW() + INTERVAL '15 minutes', 'AT_RISK', NOW() - INTERVAL '4 hours 50 minutes', NOW() - INTERVAL '5 hours', NOW() - INTERVAL '1 hour'),
    ('77777777-7777-7777-7777-777777777773', '66666666-6666-6666-6666-666666666663', '44444444-4444-4444-4444-444444444442', NOW() - INTERVAL '23 hours', NOW() + INTERVAL '3 hours', 'ON_TRACK', NOW() - INTERVAL '23 hours 30 minutes', NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 hours')
ON CONFLICT (id) DO NOTHING;

-- 10. Tasks
INSERT INTO case_tasks (id, case_id, title, status, assignee_id, created_at, updated_at)
VALUES 
    ('88888888-8888-8888-8888-888888888881', '66666666-6666-6666-6666-666666666661', 'Inspect Envoy proxy access logs for 504 timeouts', 'COMPLETED', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours'),
    ('88888888-8888-8888-8888-888888888882', '66666666-6666-6666-6666-666666666661', 'Verify Okta IDP certificate validity and DNS resolution', 'COMPLETED', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour'),
    ('88888888-8888-8888-8888-888888888883', '66666666-6666-6666-6666-666666666661', 'Scale gateway replica count from 3 to 8', 'IN_PROGRESS', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '30 minutes')
ON CONFLICT (id) DO NOTHING;

-- 11. Notifications
INSERT INTO notifications (id, user_id, case_id, type, title, message, read, created_at)
VALUES 
    ('99999999-9999-9999-9999-999999999991', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666661', 'CASE_ASSIGNED', 'New P1 Incident Assigned', 'You have been assigned to NEX-2026-0104 (Auth Gateway Timeout).', FALSE, NOW() - INTERVAL '2 hours'),
    ('99999999-9999-9999-9999-999999999992', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666662', 'SLA_WARNING', 'SLA Risk Alert: 15m remaining', 'Case NEX-2026-0087 is approaching resolution deadline.', FALSE, NOW() - INTERVAL '30 minutes'),
    ('99999999-9999-9999-9999-999999999993', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '66666666-6666-6666-6666-666666666663', 'REQUESTER_REPLIED', 'Operator requested info', 'Elena Vance requested diagnostic VPN logs for NEX-2026-0042.', FALSE, NOW() - INTERVAL '2 hours')
ON CONFLICT (id) DO NOTHING;

-- 12. Problems
INSERT INTO problems (id, organization_id, title, suspected_root_cause, confirmed_root_cause, corrective_action, preventive_action, status, created_by, created_at, updated_at)
VALUES 
    ('aaaaaaaa-1111-2222-3333-444444444441', '11111111-1111-1111-1111-111111111111', 'Intermittent TLS Handshake Stall on Envoy Edge Ingress', 'TCP Keepalive timeout shorter than client idle timeout.', 'Confirmed TCP Keepalive timeout misconfiguration.', 'Set client keepalive timeout to 45s.', 'Roll out updated Ingress Helm chart v2.4.1.', 'RESOLVED', 'dddddddd-dddd-dddd-dddd-dddddddddddd', NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- 13. Audit Logs
INSERT INTO audit_logs (id, entity_type, entity_id, action, actor_id, actor_name, actor_role, old_value, new_value, source, ip_address, created_at)
VALUES 
    (gen_random_uuid(), 'CASE', '66666666-6666-6666-6666-666666666661', 'CASE_CREATED', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Sarah Connor', 'REQUESTER', NULL, '{"title": "Authentication Gateway Timeout during SSO federation"}', 'USER', '10.0.0.12', NOW() - INTERVAL '3 hours'),
    (gen_random_uuid(), 'CASE', '66666666-6666-6666-6666-666666666661', 'CASE_ASSIGNED', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Marcus Brody', 'TEAM_LEAD', '{"assignedTo": null}', '{"assignedTo": "Elena Vance"}', 'USER', '10.0.0.1', NOW() - INTERVAL '2 hours 55 minutes'),
    (gen_random_uuid(), 'CASE', '66666666-6666-6666-6666-666666666661', 'CASE_STATUS_CHANGED', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Elena Vance', 'OPERATOR', '{"status": "ASSIGNED"}', '{"status": "INVESTIGATING"}', 'USER', '10.0.0.45', NOW() - INTERVAL '2 hours 50 minutes');
