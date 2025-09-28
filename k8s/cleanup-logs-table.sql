-- Create cleanup logs table for tracking cron job executions
-- This table will be created in the gateway schema

CREATE TABLE IF NOT EXISTS gateway.cleanup_logs (
    id BIGSERIAL PRIMARY KEY,
    job_type VARCHAR(100) NOT NULL,
    records_processed INTEGER DEFAULT 0,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED', 'PARTIAL')),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_cleanup_logs_job_type ON gateway.cleanup_logs(job_type);
CREATE INDEX IF NOT EXISTS idx_cleanup_logs_execution_time ON gateway.cleanup_logs(execution_time);
CREATE INDEX IF NOT EXISTS idx_cleanup_logs_status ON gateway.cleanup_logs(status);

-- Grant permissions
GRANT ALL PRIVILEGES ON TABLE gateway.cleanup_logs TO foodybuddy_user;
GRANT ALL PRIVILEGES ON SEQUENCE gateway.cleanup_logs_id_seq TO foodybuddy_user;
