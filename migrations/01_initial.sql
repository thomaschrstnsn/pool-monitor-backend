CREATE TABLE temperatures (
    id SERIAL PRIMARY KEY,
    time TIMESTAMPTZ NOT NULL,
	temperature DOUBLE PRECISION NOT NULL,
	addr VARCHAR(64) NOT NULL,
	reading_id UUID NOT NULL
);

CREATE INDEX index_on_reading_id ON temperatures(reading_id);
CREATE INDEX idx_on_time_brin ON temperatures USING brin (time);
