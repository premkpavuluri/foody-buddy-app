--
-- PostgreSQL database cluster dump
--

\restrict KhpSiwWqsArzz6bqJbwJwByDTCYVb5cYwX82eCMCMv6UEZXJhAvR2euYrUfEkFg

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE foodybuddy_user;
ALTER ROLE foodybuddy_user WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:+kbcTBykj6n85H18RNYlzw==$Dx63hkn0OuWXaY6ZZ1z86y/nKzlAFsX16WIpfgekS5c=:V0pjazxEWuQE2NnJ/CllY+X+R+iTtpjEwqWUzEmEDDQ=';

--
-- User Configurations
--








\unrestrict KhpSiwWqsArzz6bqJbwJwByDTCYVb5cYwX82eCMCMv6UEZXJhAvR2euYrUfEkFg

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict XIBCl2ra3IMRtmT7cdvgjpR7NednewfpMrWesJQ3i8gtIrqZZ3svWccg3T3XaLv

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict XIBCl2ra3IMRtmT7cdvgjpR7NednewfpMrWesJQ3i8gtIrqZZ3svWccg3T3XaLv

--
-- Database "foodybuddy" dump
--

--
-- PostgreSQL database dump
--

\restrict KnKssCHkLSNoTjxeGWwSpjGG4OKWKov0g3XapO29TZbcdgIIYyq6giF1XeuewxN

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: foodybuddy; Type: DATABASE; Schema: -; Owner: foodybuddy_user
--

CREATE DATABASE foodybuddy WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE foodybuddy OWNER TO foodybuddy_user;

\unrestrict KnKssCHkLSNoTjxeGWwSpjGG4OKWKov0g3XapO29TZbcdgIIYyq6giF1XeuewxN
\connect foodybuddy
\restrict KnKssCHkLSNoTjxeGWwSpjGG4OKWKov0g3XapO29TZbcdgIIYyq6giF1XeuewxN

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gateway; Type: SCHEMA; Schema: -; Owner: foodybuddy_user
--

CREATE SCHEMA gateway;


ALTER SCHEMA gateway OWNER TO foodybuddy_user;

--
-- Name: orders; Type: SCHEMA; Schema: -; Owner: foodybuddy_user
--

CREATE SCHEMA orders;


ALTER SCHEMA orders OWNER TO foodybuddy_user;

--
-- Name: payments; Type: SCHEMA; Schema: -; Owner: foodybuddy_user
--

CREATE SCHEMA payments;


ALTER SCHEMA payments OWNER TO foodybuddy_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gateway_orders; Type: TABLE; Schema: gateway; Owner: foodybuddy_user
--

CREATE TABLE gateway.gateway_orders (
    id bigint NOT NULL,
    order_id character varying(255) NOT NULL,
    payment_id character varying(255) NOT NULL,
    transaction_id character varying(255) NOT NULL,
    status character varying(50),
    user_id character varying(255),
    total_amount double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE gateway.gateway_orders OWNER TO foodybuddy_user;

--
-- Name: gateway_orders_id_seq; Type: SEQUENCE; Schema: gateway; Owner: foodybuddy_user
--

CREATE SEQUENCE gateway.gateway_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gateway.gateway_orders_id_seq OWNER TO foodybuddy_user;

--
-- Name: gateway_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: gateway; Owner: foodybuddy_user
--

ALTER SEQUENCE gateway.gateway_orders_id_seq OWNED BY gateway.gateway_orders.id;


--
-- Name: users; Type: TABLE; Schema: gateway; Owner: foodybuddy_user
--

CREATE TABLE gateway.users (
    id bigint NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE gateway.users OWNER TO foodybuddy_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: gateway; Owner: foodybuddy_user
--

CREATE SEQUENCE gateway.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gateway.users_id_seq OWNER TO foodybuddy_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: gateway; Owner: foodybuddy_user
--

ALTER SEQUENCE gateway.users_id_seq OWNED BY gateway.users.id;


--
-- Name: order_items; Type: TABLE; Schema: orders; Owner: foodybuddy_user
--

CREATE TABLE orders.order_items (
    id bigint NOT NULL,
    item_id character varying(255) NOT NULL,
    item_name character varying(255) NOT NULL,
    quantity integer NOT NULL,
    price double precision NOT NULL,
    order_id bigint
);


ALTER TABLE orders.order_items OWNER TO foodybuddy_user;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: orders; Owner: foodybuddy_user
--

CREATE SEQUENCE orders.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE orders.order_items_id_seq OWNER TO foodybuddy_user;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: orders; Owner: foodybuddy_user
--

ALTER SEQUENCE orders.order_items_id_seq OWNED BY orders.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: orders; Owner: foodybuddy_user
--

CREATE TABLE orders.orders (
    id bigint NOT NULL,
    order_id character varying(255) NOT NULL,
    total double precision NOT NULL,
    status character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE orders.orders OWNER TO foodybuddy_user;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: orders; Owner: foodybuddy_user
--

CREATE SEQUENCE orders.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE orders.orders_id_seq OWNER TO foodybuddy_user;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: orders; Owner: foodybuddy_user
--

ALTER SEQUENCE orders.orders_id_seq OWNED BY orders.orders.id;


--
-- Name: payments; Type: TABLE; Schema: payments; Owner: foodybuddy_user
--

CREATE TABLE payments.payments (
    id bigint NOT NULL,
    payment_id character varying(255) NOT NULL,
    order_id character varying(255) NOT NULL,
    amount double precision NOT NULL,
    status character varying(50),
    method character varying(50),
    transaction_id character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE payments.payments OWNER TO foodybuddy_user;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: payments; Owner: foodybuddy_user
--

CREATE SEQUENCE payments.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE payments.payments_id_seq OWNER TO foodybuddy_user;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: payments; Owner: foodybuddy_user
--

ALTER SEQUENCE payments.payments_id_seq OWNED BY payments.payments.id;


--
-- Name: transactions; Type: TABLE; Schema: payments; Owner: foodybuddy_user
--

CREATE TABLE payments.transactions (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    amount numeric(10,2) NOT NULL,
    status character varying(20) NOT NULL,
    payment_method character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE payments.transactions OWNER TO foodybuddy_user;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: payments; Owner: foodybuddy_user
--

CREATE SEQUENCE payments.transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE payments.transactions_id_seq OWNER TO foodybuddy_user;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: payments; Owner: foodybuddy_user
--

ALTER SEQUENCE payments.transactions_id_seq OWNED BY payments.transactions.id;


--
-- Name: gateway_orders id; Type: DEFAULT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.gateway_orders ALTER COLUMN id SET DEFAULT nextval('gateway.gateway_orders_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.users ALTER COLUMN id SET DEFAULT nextval('gateway.users_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: orders; Owner: foodybuddy_user
--

ALTER TABLE ONLY orders.order_items ALTER COLUMN id SET DEFAULT nextval('orders.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: orders; Owner: foodybuddy_user
--

ALTER TABLE ONLY orders.orders ALTER COLUMN id SET DEFAULT nextval('orders.orders_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: payments; Owner: foodybuddy_user
--

ALTER TABLE ONLY payments.payments ALTER COLUMN id SET DEFAULT nextval('payments.payments_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: payments; Owner: foodybuddy_user
--

ALTER TABLE ONLY payments.transactions ALTER COLUMN id SET DEFAULT nextval('payments.transactions_id_seq'::regclass);


--
-- Data for Name: gateway_orders; Type: TABLE DATA; Schema: gateway; Owner: foodybuddy_user
--

COPY gateway.gateway_orders (id, order_id, payment_id, transaction_id, status, user_id, total_amount, created_at, updated_at) FROM stdin;
1	8b53cb78-374f-469a-bf27-7e7e26ec6348	f016be3c-4605-4d11-a652-b87897a1c29e	TXN_1758044023889	CONFIRMED	test-user	10	2025-09-16 17:33:46.793068	2025-09-16 17:33:46.793085
2	2c36aa88-f0e7-4610-8d3b-a6e0fbf4d4a6	f8c67839-d1e0-44d8-bd85-94f95f7aa197	TXN_1758044129492	CONFIRMED	user-123	11.49	2025-09-16 17:35:31.5394	2025-09-16 17:35:31.539415
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: gateway; Owner: foodybuddy_user
--

COPY gateway.users (id, username, email, created_at) FROM stdin;
1	admin	admin@foodybuddy.com	2025-09-16 17:26:47.275852
2	user1	user1@foodybuddy.com	2025-09-16 17:26:47.275852
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: orders; Owner: foodybuddy_user
--

COPY orders.order_items (id, item_id, item_name, quantity, price, order_id) FROM stdin;
1	1	test	1	10	2
2	1	test	1	10	3
3	1	test	1	10	4
4	1	test	1	10	5
5	4	Pasta Primavera	1	11.49	6
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: orders; Owner: foodybuddy_user
--

COPY orders.orders (id, order_id, total, status, created_at, updated_at) FROM stdin;
2	eafb9777-ff78-4ded-8a9d-2c391e274810	10	PENDING	2025-09-16 17:32:10.561371	2025-09-16 17:32:10.561384
3	8f1d5e5b-0f39-4b6b-9041-fdd630da099c	10	PENDING	2025-09-16 17:32:17.3244	2025-09-16 17:32:17.324418
4	7b60f510-ca86-4439-8ac6-437e2c33a090	10	PENDING	2025-09-16 17:32:51.946169	2025-09-16 17:32:51.946185
5	8b53cb78-374f-469a-bf27-7e7e26ec6348	10	CONFIRMED	2025-09-16 17:33:43.878027	2025-09-16 17:33:46.592838
6	2c36aa88-f0e7-4610-8d3b-a6e0fbf4d4a6	11.49	CONFIRMED	2025-09-16 17:35:29.478235	2025-09-16 17:35:31.525488
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: payments; Owner: foodybuddy_user
--

COPY payments.payments (id, payment_id, order_id, amount, status, method, transaction_id, created_at, updated_at) FROM stdin;
1	073faf46-7bb3-463e-b787-da1d5ba3138a	test-order	10	COMPLETED	\N	TXN_1758043963510	2025-09-16 17:32:43.510631	2025-09-16 17:32:45.51458
2	f016be3c-4605-4d11-a652-b87897a1c29e	8b53cb78-374f-469a-bf27-7e7e26ec6348	10	COMPLETED	CREDIT_CARD	TXN_1758044023889	2025-09-16 17:33:43.889656	2025-09-16 17:33:45.889987
3	f8c67839-d1e0-44d8-bd85-94f95f7aa197	2c36aa88-f0e7-4610-8d3b-a6e0fbf4d4a6	11.49	COMPLETED	CREDIT_CARD	TXN_1758044129492	2025-09-16 17:35:29.492215	2025-09-16 17:35:31.494554
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: payments; Owner: foodybuddy_user
--

COPY payments.transactions (id, order_id, amount, status, payment_method, created_at) FROM stdin;
\.


--
-- Name: gateway_orders_id_seq; Type: SEQUENCE SET; Schema: gateway; Owner: foodybuddy_user
--

SELECT pg_catalog.setval('gateway.gateway_orders_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: gateway; Owner: foodybuddy_user
--

SELECT pg_catalog.setval('gateway.users_id_seq', 2, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: orders; Owner: foodybuddy_user
--

SELECT pg_catalog.setval('orders.order_items_id_seq', 5, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: orders; Owner: foodybuddy_user
--

SELECT pg_catalog.setval('orders.orders_id_seq', 6, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: payments; Owner: foodybuddy_user
--

SELECT pg_catalog.setval('payments.payments_id_seq', 3, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: payments; Owner: foodybuddy_user
--

SELECT pg_catalog.setval('payments.transactions_id_seq', 1, false);


--
-- Name: gateway_orders gateway_orders_order_id_key; Type: CONSTRAINT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.gateway_orders
    ADD CONSTRAINT gateway_orders_order_id_key UNIQUE (order_id);


--
-- Name: gateway_orders gateway_orders_pkey; Type: CONSTRAINT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.gateway_orders
    ADD CONSTRAINT gateway_orders_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: gateway; Owner: foodybuddy_user
--

ALTER TABLE ONLY gateway.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: orders; Owner: foodybuddy_user
--

ALTER TABLE ONLY orders.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: orders; Owner: foodybuddy_user
--

ALTER TABLE ONLY orders.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payments payments_payment_id_key; Type: CONSTRAINT; Schema: payments; Owner: foodybuddy_user
--

ALTER TABLE ONLY payments.payments
    ADD CONSTRAINT payments_payment_id_key UNIQUE (payment_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: payments; Owner: foodybuddy_user
--

ALTER TABLE ONLY payments.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: payments; Owner: foodybuddy_user
--

ALTER TABLE ONLY payments.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: idx_gateway_users_username; Type: INDEX; Schema: gateway; Owner: foodybuddy_user
--

CREATE INDEX idx_gateway_users_username ON gateway.users USING btree (username);


--
-- Name: idx_payments_transactions_order_id; Type: INDEX; Schema: payments; Owner: foodybuddy_user
--

CREATE INDEX idx_payments_transactions_order_id ON payments.transactions USING btree (order_id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: orders; Owner: foodybuddy_user
--

ALTER TABLE ONLY orders.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders.orders(id);


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: gateway; Owner: foodybuddy_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE foodybuddy_user IN SCHEMA gateway GRANT ALL ON TABLES  TO foodybuddy_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: orders; Owner: foodybuddy_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE foodybuddy_user IN SCHEMA orders GRANT ALL ON TABLES  TO foodybuddy_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: payments; Owner: foodybuddy_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE foodybuddy_user IN SCHEMA payments GRANT ALL ON TABLES  TO foodybuddy_user;


--
-- PostgreSQL database dump complete
--

\unrestrict KnKssCHkLSNoTjxeGWwSpjGG4OKWKov0g3XapO29TZbcdgIIYyq6giF1XeuewxN

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict bkucvUOOtNbRHJWMRekidt9UILJEMDPKBzBnLmLyV1HSsP1wgDFVsuPO0bqsLEc

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict bkucvUOOtNbRHJWMRekidt9UILJEMDPKBzBnLmLyV1HSsP1wgDFVsuPO0bqsLEc

--
-- PostgreSQL database cluster dump complete
--

