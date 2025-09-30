-- Extracted menuca_v3 schema objects (schema, types, function, tables, sequences, defaults, constraints, indexes, triggers)

-- Schema
CREATE SCHEMA IF NOT EXISTS menuca_v3;
ALTER SCHEMA menuca_v3 OWNER TO postgres;

-- Function
CREATE OR REPLACE FUNCTION menuca_v3.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END $$;
ALTER FUNCTION menuca_v3.set_updated_at() OWNER TO postgres;

-- Types (referenced from public)
-- Assumes public.restaurant_status and public.service_type already exist

-- Tables and sequences

-- restaurants
CREATE TABLE IF NOT EXISTS menuca_v3.restaurants (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    legacy_v1_id integer,
    legacy_v2_id integer,
    name character varying(255) NOT NULL,
    status public.restaurant_status DEFAULT 'pending'::public.restaurant_status NOT NULL,
    activated_at timestamp with time zone,
    suspended_at timestamp with time zone,
    closed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by integer,
    updated_at timestamp with time zone,
    updated_by integer
);
ALTER TABLE menuca_v3.restaurants OWNER TO postgres;
CREATE SEQUENCE IF NOT EXISTS menuca_v3.restaurants_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE menuca_v3.restaurants_id_seq OWNER TO postgres;
ALTER SEQUENCE menuca_v3.restaurants_id_seq OWNED BY menuca_v3.restaurants.id;
ALTER TABLE ONLY menuca_v3.restaurants ALTER COLUMN id SET DEFAULT nextval('menuca_v3.restaurants_id_seq'::regclass);
ALTER TABLE ONLY menuca_v3.restaurants ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);
ALTER TABLE ONLY menuca_v3.restaurants ADD CONSTRAINT restaurants_uuid_key UNIQUE (uuid);
CREATE INDEX IF NOT EXISTS idx_restaurants_legacy ON menuca_v3.restaurants USING btree (legacy_v1_id, legacy_v2_id);
CREATE INDEX IF NOT EXISTS idx_restaurants_status ON menuca_v3.restaurants USING btree (status);
CREATE TRIGGER trg_restaurants_updated_at BEFORE UPDATE ON menuca_v3.restaurants FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

-- restaurant_locations
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_locations (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    restaurant_id bigint NOT NULL,
    is_primary boolean DEFAULT true NOT NULL,
    street_address character varying(255),
    unit_number character varying(20),
    city character varying(100),
    province_id integer,
    postal_code character varying(15),
    country_code character(2) DEFAULT 'CA'::bpchar,
    latitude numeric(13,10),
    longitude numeric(13,10),
    phone character varying(20),
    email character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);
ALTER TABLE menuca_v3.restaurant_locations OWNER TO postgres;
CREATE SEQUENCE IF NOT EXISTS menuca_v3.restaurant_locations_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE menuca_v3.restaurant_locations_id_seq OWNER TO postgres;
ALTER SEQUENCE menuca_v3.restaurant_locations_id_seq OWNED BY menuca_v3.restaurant_locations.id;
ALTER TABLE ONLY menuca_v3.restaurant_locations ALTER COLUMN id SET DEFAULT nextval('menuca_v3.restaurant_locations_id_seq'::regclass);
ALTER TABLE ONLY menuca_v3.restaurant_locations ADD CONSTRAINT restaurant_locations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY menuca_v3.restaurant_locations ADD CONSTRAINT restaurant_locations_uuid_key UNIQUE (uuid);
CREATE INDEX IF NOT EXISTS idx_locations_city ON menuca_v3.restaurant_locations USING btree (city);
CREATE INDEX IF NOT EXISTS idx_locations_coords ON menuca_v3.restaurant_locations USING btree (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_locations_restaurant ON menuca_v3.restaurant_locations USING btree (restaurant_id);
CREATE TRIGGER trg_locations_updated_at BEFORE UPDATE ON menuca_v3.restaurant_locations FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

-- restaurant_domains
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_domains (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    restaurant_id bigint NOT NULL,
    domain character varying(255) NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    disabled_at timestamp with time zone,
    updated_at timestamp with time zone
);
ALTER TABLE menuca_v3.restaurant_domains OWNER TO postgres;
CREATE SEQUENCE IF NOT EXISTS menuca_v3.restaurant_domains_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE menuca_v3.restaurant_domains_id_seq OWNER TO postgres;
ALTER SEQUENCE menuca_v3.restaurant_domains_id_seq OWNED BY menuca_v3.restaurant_domains.id;
ALTER TABLE ONLY menuca_v3.restaurant_domains ALTER COLUMN id SET DEFAULT nextval('menuca_v3.restaurant_domains_id_seq'::regclass);
ALTER TABLE ONLY menuca_v3.restaurant_domains ADD CONSTRAINT restaurant_domains_pkey PRIMARY KEY (id);
ALTER TABLE ONLY menuca_v3.restaurant_domains ADD CONSTRAINT restaurant_domains_uuid_key UNIQUE (uuid);
CREATE UNIQUE INDEX IF NOT EXISTS u_restaurant_domain ON menuca_v3.restaurant_domains USING btree (restaurant_id, domain);
CREATE TRIGGER trg_domains_updated_at BEFORE UPDATE ON menuca_v3.restaurant_domains FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

-- restaurant_contacts
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_contacts (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    restaurant_id bigint NOT NULL,
    title character varying(100),
    first_name character varying(100),
    last_name character varying(100),
    email character varying(255),
    phone character varying(20),
    receives_orders boolean DEFAULT false,
    receives_statements boolean DEFAULT false,
    receives_marketing boolean DEFAULT false,
    preferred_language character(2) DEFAULT 'en'::bpchar,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);
ALTER TABLE menuca_v3.restaurant_contacts OWNER TO postgres;
CREATE SEQUENCE IF NOT EXISTS menuca_v3.restaurant_contacts_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE menuca_v3.restaurant_contacts_id_seq OWNER TO postgres;
ALTER SEQUENCE menuca_v3.restaurant_contacts_id_seq OWNED BY menuca_v3.restaurant_contacts.id;
ALTER TABLE ONLY menuca_v3.restaurant_contacts ALTER COLUMN id SET DEFAULT nextval('menuca_v3.restaurant_contacts_id_seq'::regclass);
ALTER TABLE ONLY menuca_v3.restaurant_contacts ADD CONSTRAINT restaurant_contacts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY menuca_v3.restaurant_contacts ADD CONSTRAINT restaurant_contacts_uuid_key UNIQUE (uuid);
CREATE INDEX IF NOT EXISTS idx_contacts_email ON menuca_v3.restaurant_contacts USING btree (email);
CREATE INDEX IF NOT EXISTS idx_contacts_restaurant ON menuca_v3.restaurant_contacts USING btree (restaurant_id);
CREATE TRIGGER trg_contacts_updated_at BEFORE UPDATE ON menuca_v3.restaurant_contacts FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

-- restaurant_admin_users
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_admin_users (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    restaurant_id bigint NOT NULL,
    user_type character varying(1) DEFAULT 'r'::character varying,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(255) NOT NULL,
    password_hash character varying(255),
    last_login timestamp with time zone,
    login_count integer DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL,
    send_statement boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);
ALTER TABLE menuca_v3.restaurant_admin_users OWNER TO postgres;
CREATE SEQUENCE IF NOT EXISTS menuca_v3.restaurant_admin_users_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE menuca_v3.restaurant_admin_users_id_seq OWNER TO postgres;
ALTER SEQUENCE menuca_v3.restaurant_admin_users_id_seq OWNED BY menuca_v3.restaurant_admin_users.id;
ALTER TABLE ONLY menuca_v3.restaurant_admin_users ALTER COLUMN id SET DEFAULT nextval('menuca_v3.restaurant_admin_users_id_seq'::regclass);
ALTER TABLE ONLY menuca_v3.restaurant_admin_users ADD CONSTRAINT restaurant_admin_users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY menuca_v3.restaurant_admin_users ADD CONSTRAINT restaurant_admin_users_uuid_key UNIQUE (uuid);
CREATE UNIQUE INDEX IF NOT EXISTS u_admin_email_per_restaurant ON menuca_v3.restaurant_admin_users USING btree (restaurant_id, email);
CREATE TRIGGER trg_admin_users_updated_at BEFORE UPDATE ON menuca_v3.restaurant_admin_users FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

-- restaurant_schedules
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_schedules (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    restaurant_id bigint NOT NULL,
    type public.service_type NOT NULL,
    day_start smallint NOT NULL,
    time_start time without time zone NOT NULL,
    time_stop time without time zone NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    day_stop smallint NOT NULL,
    CONSTRAINT restaurant_schedules_day_start_check CHECK (((day_start >= 1) AND (day_start <= 7))),
    CONSTRAINT restaurant_schedules_day_stop_check CHECK (((day_stop >= 1) AND (day_stop <= 7)))
);
ALTER TABLE menuca_v3.restaurant_schedules OWNER TO postgres;
CREATE SEQUENCE IF NOT EXISTS menuca_v3.restaurant_schedules_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE menuca_v3.restaurant_schedules_id_seq OWNER TO postgres;
ALTER SEQUENCE menuca_v3.restaurant_schedules_id_seq OWNED BY menuca_v3.restaurant_schedules.id;
ALTER TABLE ONLY menuca_v3.restaurant_schedules ALTER COLUMN id SET DEFAULT nextval('menuca_v3.restaurant_schedules_id_seq'::regclass);
ALTER TABLE ONLY menuca_v3.restaurant_schedules ADD CONSTRAINT restaurant_schedules_pkey PRIMARY KEY (id);
ALTER TABLE ONLY menuca_v3.restaurant_schedules ADD CONSTRAINT restaurant_schedules_uuid_key UNIQUE (uuid);
CREATE INDEX IF NOT EXISTS idx_schedules_restaurant ON menuca_v3.restaurant_schedules USING btree (restaurant_id);
CREATE UNIQUE INDEX IF NOT EXISTS u_sched_restaurant_service_day ON menuca_v3.restaurant_schedules USING btree (restaurant_id, type, day_start, time_start, time_stop);
CREATE TRIGGER trg_schedules_updated_at BEFORE UPDATE ON menuca_v3.restaurant_schedules FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();

