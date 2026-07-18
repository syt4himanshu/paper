--
-- PostgreSQL database dump
--

\restrict cROQrr7rcnwfP7Fa6i65FVbpHniGzTvPHRB1MSutVTbPtz9LwpnxdOWac2Clhn5

-- Dumped from database version 18.4 (Homebrew)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: ration_category; Type: TYPE; Schema: public; Owner: himanshumire
--

CREATE TYPE public.ration_category AS ENUM (
    'APL',
    'BPL',
    'AAY'
);


ALTER TYPE public.ration_category OWNER TO himanshumire;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: himanshumire
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'shopkeeper',
    'beneficiary'
);


ALTER TYPE public.user_role OWNER TO himanshumire;

--
-- Name: prevent_admin_user_delete(); Type: FUNCTION; Schema: public; Owner: himanshumire
--

CREATE FUNCTION public.prevent_admin_user_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF OLD.role = 'admin' OR LOWER(COALESCE(OLD.email, '')) = 'admin@pds.gov' THEN
        RAISE EXCEPTION 'Admin users cannot be deleted';
      END IF;

      RETURN OLD;
    END;
    $$;


ALTER FUNCTION public.prevent_admin_user_delete() OWNER TO himanshumire;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: areas; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.areas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.areas OWNER TO himanshumire;

--
-- Name: blockchain_logs; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.blockchain_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    transaction_id uuid NOT NULL,
    tx_hash text,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    block_number bigint,
    attempts integer DEFAULT 0 NOT NULL,
    last_error text,
    submitted_at timestamp without time zone DEFAULT now() NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT blockchain_logs_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'failed'::character varying])::text[])))
);


ALTER TABLE public.blockchain_logs OWNER TO himanshumire;

--
-- Name: family_members; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.family_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ration_card_id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    age integer NOT NULL,
    is_head boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT family_members_age_check CHECK (((age >= 0) AND (age <= 120)))
);


ALTER TABLE public.family_members OWNER TO himanshumire;

--
-- Name: otp_verifications; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.otp_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    mobile character varying(15) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone DEFAULT (now() + '00:10:00'::interval) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.otp_verifications OWNER TO himanshumire;

--
-- Name: policies; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.policies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category public.ration_category NOT NULL,
    rice_per_person_kg numeric(5,2) DEFAULT 0 NOT NULL,
    wheat_per_person_kg numeric(5,2) DEFAULT 0 NOT NULL,
    sugar_per_person_kg numeric(5,2) DEFAULT 0 NOT NULL,
    validity_days integer DEFAULT 30 NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.policies OWNER TO himanshumire;

--
-- Name: qr_sessions; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.qr_sessions (
    session_id character varying(64) NOT NULL,
    ration_card_id uuid NOT NULL,
    shop_id uuid NOT NULL,
    issued_to_user_id uuid,
    expires_at timestamp without time zone NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    used_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.qr_sessions OWNER TO himanshumire;

--
-- Name: ration_cards; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.ration_cards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    card_number character varying(50) NOT NULL,
    category public.ration_category NOT NULL,
    head_user_id uuid NOT NULL,
    shop_id uuid NOT NULL,
    area_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    address text
);


ALTER TABLE public.ration_cards OWNER TO himanshumire;

--
-- Name: shops; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.shops (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    shop_code character varying(20) NOT NULL,
    shop_name character varying(150) NOT NULL,
    area_id uuid NOT NULL,
    shopkeeper_id uuid,
    address text,
    contact_number character varying(15),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shops OWNER TO himanshumire;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ration_card_id uuid NOT NULL,
    shop_id uuid NOT NULL,
    served_by uuid,
    rice_qty_kg numeric(8,2) DEFAULT 0 NOT NULL,
    wheat_qty_kg numeric(8,2) DEFAULT 0 NOT NULL,
    sugar_qty_kg numeric(8,2) DEFAULT 0 NOT NULL,
    blockchain_tx_hash text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT transactions_rice_qty_kg_check CHECK ((rice_qty_kg >= (0)::numeric)),
    CONSTRAINT transactions_sugar_qty_kg_check CHECK ((sugar_qty_kg >= (0)::numeric)),
    CONSTRAINT transactions_wheat_qty_kg_check CHECK ((wheat_qty_kg >= (0)::numeric))
);


ALTER TABLE public.transactions OWNER TO himanshumire;

--
-- Name: users; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role public.user_role NOT NULL,
    name character varying(150),
    email character varying(255),
    mobile character varying(15),
    password_hash text,
    address text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    gender character varying(10),
    age integer
);


ALTER TABLE public.users OWNER TO himanshumire;

--
-- Name: wallets; Type: TABLE; Schema: public; Owner: himanshumire
--

CREATE TABLE public.wallets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ration_card_id uuid NOT NULL,
    rice_balance_kg numeric(8,2) DEFAULT 0 NOT NULL,
    wheat_balance_kg numeric(8,2) DEFAULT 0 NOT NULL,
    sugar_balance_kg numeric(8,2) DEFAULT 0 NOT NULL,
    last_reset_date date,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallets_rice_balance_kg_check CHECK ((rice_balance_kg >= (0)::numeric)),
    CONSTRAINT wallets_sugar_balance_kg_check CHECK ((sugar_balance_kg >= (0)::numeric)),
    CONSTRAINT wallets_wheat_balance_kg_check CHECK ((wheat_balance_kg >= (0)::numeric))
);


ALTER TABLE public.wallets OWNER TO himanshumire;

--
-- Name: v_beneficiaries; Type: VIEW; Schema: public; Owner: himanshumire
--

CREATE VIEW public.v_beneficiaries AS
 SELECT rc.id AS ration_card_id,
    rc.card_number,
    rc.category,
    rc.is_active,
    fm.name AS head_name,
    u.mobile,
    s.shop_code,
    s.shop_name,
    a.name AS area_name,
    w.rice_balance_kg,
    w.wheat_balance_kg,
    w.sugar_balance_kg,
    (( SELECT count(*) AS count
           FROM public.family_members fm2
          WHERE (fm2.ration_card_id = rc.id)))::integer AS family_size,
    rc.created_at
   FROM (((((public.ration_cards rc
     JOIN public.family_members fm ON (((fm.ration_card_id = rc.id) AND (fm.is_head = true))))
     JOIN public.users u ON ((u.id = fm.user_id)))
     JOIN public.shops s ON ((s.id = rc.shop_id)))
     JOIN public.areas a ON ((a.id = rc.area_id)))
     LEFT JOIN public.wallets w ON ((w.ration_card_id = rc.id)));


ALTER VIEW public.v_beneficiaries OWNER TO himanshumire;

--
-- Name: v_blockchain_pending; Type: VIEW; Schema: public; Owner: himanshumire
--

CREATE VIEW public.v_blockchain_pending AS
 SELECT bl.id,
    bl.transaction_id,
    bl.tx_hash,
    bl.attempts,
    bl.last_error,
    bl.submitted_at,
    t.ration_card_id,
    t.shop_id,
    t.rice_qty_kg,
    t.wheat_qty_kg,
    t.sugar_qty_kg,
    t.created_at AS transaction_date
   FROM (public.blockchain_logs bl
     JOIN public.transactions t ON ((t.id = bl.transaction_id)))
  WHERE ((bl.status)::text = 'pending'::text)
  ORDER BY bl.submitted_at;


ALTER VIEW public.v_blockchain_pending OWNER TO himanshumire;

--
-- Name: v_shop_summary; Type: VIEW; Schema: public; Owner: himanshumire
--

CREATE VIEW public.v_shop_summary AS
 SELECT s.id,
    s.shop_code,
    s.shop_name,
    a.name AS area_name,
    u.name AS shopkeeper_name,
    u.mobile AS shopkeeper_mobile,
    (count(DISTINCT rc.id))::integer AS total_ration_cards,
    (count(DISTINCT t.id))::integer AS total_transactions
   FROM ((((public.shops s
     JOIN public.areas a ON ((a.id = s.area_id)))
     LEFT JOIN public.users u ON ((u.id = s.shopkeeper_id)))
     LEFT JOIN public.ration_cards rc ON ((rc.shop_id = s.id)))
     LEFT JOIN public.transactions t ON ((t.shop_id = s.id)))
  GROUP BY s.id, s.shop_code, s.shop_name, a.name, u.name, u.mobile;


ALTER VIEW public.v_shop_summary OWNER TO himanshumire;

--
-- Name: v_transactions; Type: VIEW; Schema: public; Owner: himanshumire
--

CREATE VIEW public.v_transactions AS
 SELECT t.id,
    t.created_at,
    rc.card_number,
    rc.category,
    s.shop_name,
    u.name AS served_by_name,
    t.rice_qty_kg,
    t.wheat_qty_kg,
    t.sugar_qty_kg,
    t.blockchain_tx_hash,
    bl.status AS blockchain_status,
    bl.confirmed_at AS blockchain_confirmed_at
   FROM ((((public.transactions t
     JOIN public.ration_cards rc ON ((rc.id = t.ration_card_id)))
     JOIN public.shops s ON ((s.id = t.shop_id)))
     LEFT JOIN public.users u ON ((u.id = t.served_by)))
     LEFT JOIN public.blockchain_logs bl ON ((bl.transaction_id = t.id)));


ALTER VIEW public.v_transactions OWNER TO himanshumire;

--
-- Data for Name: areas; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.areas (id, name, is_active, created_at) FROM stdin;
0a42a076-330f-4b47-aa4e-531598a9943c	Manewada	t	2026-06-28 13:53:22.027198
b3ebf8c5-c130-4717-b406-f3087aad2bb7	Manish Nagar	t	2026-06-28 13:53:33.432444
174173df-03b8-4dfb-807c-73f3c633e45e	Dharampeth	t	2026-06-28 13:53:44.495011
\.


--
-- Data for Name: blockchain_logs; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.blockchain_logs (id, transaction_id, tx_hash, status, block_number, attempts, last_error, submitted_at, confirmed_at) FROM stdin;
\.


--
-- Data for Name: family_members; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.family_members (id, ration_card_id, user_id, name, age, is_head, created_at) FROM stdin;
328c6b85-55bd-485b-b499-339d0d3af290	f556693d-e0fd-4c91-9d30-572eb0ebf01f	941aca8b-100f-4c38-af25-321d03d783c8	Rajesh Wankhede	39	t	2026-06-28 14:55:34.945119
54d22349-820a-4bda-bf5e-fd04f19ffad6	5e3d5be1-5010-40e4-a1d1-1c0660e4c73d	91eadd04-0667-40f5-b257-98f0be21e518	Suresh Deshmukh	43	t	2026-06-28 14:55:34.992192
a0260a6d-4029-45dd-a6bd-a472b6b4ce27	029dbd90-797b-47a5-9aac-ae8512059d93	8917e2b3-42ed-4b8f-aca1-a16bcba0d90e	Sunita Gajbhiye	36	t	2026-06-28 14:55:35.019299
e025795e-0ae6-4d48-a651-ac547369e3eb	405d8973-b424-4b61-9954-711b249b448b	e984d574-8bcb-4640-aeb7-e808426bc0e8	Mahesh Borkar	47	t	2026-06-28 14:55:35.022874
fdcca0ad-f991-447a-83bb-1d0128af784b	8424d36a-e3ea-4e39-a8a7-f0d4292ca78f	849f6922-3c04-4f54-b303-03e3ab25182b	Anita Kale	40	t	2026-06-28 14:55:35.025852
e9ebd315-e3ee-4e52-a22c-191cd45f940f	9ccdb76a-657b-42f5-a719-d406f462a349	00e76737-bbf7-4466-ab5e-1c6550428098	Vijay Padole	50	t	2026-06-28 14:55:35.02839
600a68ea-f595-48d4-b733-139a6a6210c5	428780e3-e99e-49cb-9112-380c1978ac35	00f68a1e-8965-43ce-93af-9a455420377e	Meena Thakre	35	t	2026-06-28 14:55:35.035945
598124ae-a673-4bdf-b580-9545ed2cf074	3acb8cb2-2904-4304-8baf-a7a37017f986	4daf03f3-8981-44b6-9209-f7e49c1e77e4	Ramesh Kalambe	44	t	2026-06-28 14:55:35.04064
f3ec318d-3f3b-4b09-96cb-233aae882ad7	552b5cdd-0c24-4fac-af9b-6e088bd99f4b	048e7714-50d3-4182-8301-80ec4593b035	Kavita Wankhede	38	t	2026-06-28 14:55:35.043231
85ab1384-3b64-4c6d-9b09-2744e7bd59bd	30795952-ad2f-4255-9996-d52db050d9ef	02e3af29-3f00-4c57-bb3a-62ef7253099a	Prakash Ghughe	46	t	2026-06-28 14:55:35.046918
\.


--
-- Data for Name: otp_verifications; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.otp_verifications (id, mobile, status, is_used, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: policies; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.policies (id, category, rice_per_person_kg, wheat_per_person_kg, sugar_per_person_kg, validity_days, updated_at) FROM stdin;
a61cd9af-4ed0-4ee5-9312-f70c8fbfad76	APL	3.00	2.00	0.50	30	2026-06-28 13:33:42.651198
b904ce53-edc2-41cc-b164-f8641940ed86	BPL	5.00	3.00	1.00	30	2026-06-28 13:33:42.651198
9730ca57-400e-457d-afd1-bd690c4a9aba	AAY	7.00	8.00	1.00	30	2026-06-28 13:33:42.651198
\.


--
-- Data for Name: qr_sessions; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.qr_sessions (session_id, ration_card_id, shop_id, issued_to_user_id, expires_at, is_used, used_at, created_at) FROM stdin;
\.


--
-- Data for Name: ration_cards; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.ration_cards (id, card_number, category, head_user_id, shop_id, area_id, is_active, created_at, address) FROM stdin;
f556693d-e0fd-4c91-9d30-572eb0ebf01f	PDS-2026-335A154F	APL	941aca8b-100f-4c38-af25-321d03d783c8	148bf4bf-2817-4d6b-8be5-0a4cca73dbdc	174173df-03b8-4dfb-807c-73f3c633e45e	t	2026-06-28 14:55:34.945119	House No. 12, Dharampeth, Nagpur
5e3d5be1-5010-40e4-a1d1-1c0660e4c73d	PDS-2026-E8F89E18	BPL	91eadd04-0667-40f5-b257-98f0be21e518	429746cf-b17e-40d2-99b5-89c1eb86f5dd	174173df-03b8-4dfb-807c-73f3c633e45e	t	2026-06-28 14:55:34.992192	Near Hanuman Mandir, Dharampeth, Nagpur
029dbd90-797b-47a5-9aac-ae8512059d93	PDS-2026-5AB31222	APL	8917e2b3-42ed-4b8f-aca1-a16bcba0d90e	2c9d8e8c-ba48-4b1b-82cb-131afbc5ff22	174173df-03b8-4dfb-807c-73f3c633e45e	t	2026-06-28 14:55:35.019299	Plot 28, Dharampeth, Nagpur
405d8973-b424-4b61-9954-711b249b448b	PDS-2026-F7C8A657	AAY	e984d574-8bcb-4640-aeb7-e808426bc0e8	6ebeb094-7fd9-44a0-97b1-7cb9c290ec8f	0a42a076-330f-4b47-aa4e-531598a9943c	t	2026-06-28 14:55:35.022874	Ward 5, Manewada, Nagpur
8424d36a-e3ea-4e39-a8a7-f0d4292ca78f	PDS-2026-86783D9C	BPL	849f6922-3c04-4f54-b303-03e3ab25182b	4c31e447-02e1-440c-8d28-35fe9a23f365	0a42a076-330f-4b47-aa4e-531598a9943c	t	2026-06-28 14:55:35.025852	Near Water Tank, Manewada, Nagpur
9ccdb76a-657b-42f5-a719-d406f462a349	PDS-2026-F34F1A05	APL	00e76737-bbf7-4466-ab5e-1c6550428098	87e56cc8-a86f-4e41-b762-c7ff7f1648aa	0a42a076-330f-4b47-aa4e-531598a9943c	t	2026-06-28 14:55:35.02839	Main Road, Manewada, Nagpur
428780e3-e99e-49cb-9112-380c1978ac35	PDS-2026-0EF8A53A	APL	00f68a1e-8965-43ce-93af-9a455420377e	5d7d291a-c974-4320-934e-39c5573dfd66	b3ebf8c5-c130-4717-b406-f3087aad2bb7	t	2026-06-28 14:55:35.035945	Sector 1, Manish Nagar, Nagpur
3acb8cb2-2904-4304-8baf-a7a37017f986	PDS-2026-807F75AB	BPL	4daf03f3-8981-44b6-9209-f7e49c1e77e4	031a9b97-ae7e-4702-a94f-51533aee1712	b3ebf8c5-c130-4717-b406-f3087aad2bb7	t	2026-06-28 14:55:35.04064	Near Garden, Manish Nagar, Nagpur
552b5cdd-0c24-4fac-af9b-6e088bd99f4b	PDS-2026-F4DCCF6C	APL	048e7714-50d3-4182-8301-80ec4593b035	9430cb52-5374-47df-91ff-7dd19d127e4c	b3ebf8c5-c130-4717-b406-f3087aad2bb7	t	2026-06-28 14:55:35.043231	Plot 44, Manish Nagar, Nagpur
30795952-ad2f-4255-9996-d52db050d9ef	PDS-2026-7A9BAEE1	AAY	02e3af29-3f00-4c57-bb3a-62ef7253099a	148bf4bf-2817-4d6b-8be5-0a4cca73dbdc	174173df-03b8-4dfb-807c-73f3c633e45e	t	2026-06-28 14:55:35.046918	Near School, Dharampeth, Nagpur
\.


--
-- Data for Name: shops; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.shops (id, shop_code, shop_name, area_id, shopkeeper_id, address, contact_number, is_active, created_at) FROM stdin;
148bf4bf-2817-4d6b-8be5-0a4cca73dbdc	DHR-001	Dharampeth Fair Price Shop 1	174173df-03b8-4dfb-807c-73f3c633e45e	b3a9d263-dbf7-4f66-87eb-b296177b80d1	\N	\N	t	2026-06-28 14:25:53.499895
429746cf-b17e-40d2-99b5-89c1eb86f5dd	DHR-002	Dharampeth Fair Price Shop 2	174173df-03b8-4dfb-807c-73f3c633e45e	2c7f1ebb-3a3f-45a4-9fbc-af9888a29650	\N	\N	t	2026-06-28 14:25:53.559799
2c9d8e8c-ba48-4b1b-82cb-131afbc5ff22	DHR-003	Dharampeth Fair Price Shop 3	174173df-03b8-4dfb-807c-73f3c633e45e	079b52cf-d2e9-4b4f-b69c-62035309085e	\N	\N	t	2026-06-28 14:25:53.562434
6ebeb094-7fd9-44a0-97b1-7cb9c290ec8f	MNW-001	Manewada Fair Price Shop 1	0a42a076-330f-4b47-aa4e-531598a9943c	5657b6b4-053c-4fa4-9a6c-1d51333cb845	\N	\N	t	2026-06-28 14:25:53.566323
4c31e447-02e1-440c-8d28-35fe9a23f365	MNW-002	Manewada Fair Price Shop 2	0a42a076-330f-4b47-aa4e-531598a9943c	92fe900d-802f-49d2-b712-4316227cc951	\N	\N	t	2026-06-28 14:25:53.570597
87e56cc8-a86f-4e41-b762-c7ff7f1648aa	MNW-003	Manewada Fair Price Shop 3	0a42a076-330f-4b47-aa4e-531598a9943c	c3807866-c1cb-44d3-b1fb-20cee7786064	\N	\N	t	2026-06-28 14:25:53.571841
5d7d291a-c974-4320-934e-39c5573dfd66	MNG-001	Manish Nagar Fair Price Shop 1	b3ebf8c5-c130-4717-b406-f3087aad2bb7	e117272a-04c6-40d8-a61c-0dae26685212	\N	\N	t	2026-06-28 14:25:53.57306
031a9b97-ae7e-4702-a94f-51533aee1712	MNG-002	Manish Nagar Fair Price Shop 2	b3ebf8c5-c130-4717-b406-f3087aad2bb7	02ead181-7083-477a-885d-07730d20f6e7	\N	\N	t	2026-06-28 14:25:53.578878
9430cb52-5374-47df-91ff-7dd19d127e4c	MNG-003	Manish Nagar Fair Price Shop 3	b3ebf8c5-c130-4717-b406-f3087aad2bb7	642bc832-4fd9-4fa5-bcc2-281d936e6bed	\N	\N	t	2026-06-28 14:25:53.580015
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.transactions (id, ration_card_id, shop_id, served_by, rice_qty_kg, wheat_qty_kg, sugar_qty_kg, blockchain_tx_hash, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.users (id, role, name, email, mobile, password_hash, address, is_active, created_at, gender, age) FROM stdin;
2c7f1ebb-3a3f-45a4-9fbc-af9888a29650	shopkeeper	Prashant Thakre	prashant.thakre@pds.gov	+919823010002	$2b$10$jz2wLl/m5AL5z.LJzKGkfOrvltF1jbSO.wsYAhVrorxWyKj0j1xgy	\N	t	2026-06-28 14:10:47.517069	\N	\N
079b52cf-d2e9-4b4f-b69c-62035309085e	shopkeeper	Sachin Kalambe	sachin.kalambe@pds.gov	+919823010003	$2b$10$hLxWpo0i1FOcBGOMFYnOsem8vCLsplCcHkilztIr.TxfBJMib2U0C	\N	t	2026-06-28 14:10:47.577224	\N	\N
5657b6b4-053c-4fa4-9a6c-1d51333cb845	shopkeeper	Rohit Deshmukh	rohit.deshmukh@pds.gov	+919823020001	$2b$10$qOOru3XFH.vGwZStEUzOxuvhx4zN/BZWXSKbTQzDdhggyi/laDUf6	\N	t	2026-06-28 14:10:47.643473	\N	\N
92fe900d-802f-49d2-b712-4316227cc951	shopkeeper	Anil Gajbhiye	anil.gajbhiye@pds.gov	+919823020002	$2b$10$r00pC572rG6JVYcyzFeNru2HgeG6l3YgLWpWl7DoDTFEzBAF8ZkRS	\N	t	2026-06-28 14:10:47.701955	\N	\N
c3807866-c1cb-44d3-b1fb-20cee7786064	shopkeeper	Nitin Borkar	nitin.borkar@pds.gov	+919823020003	$2b$10$Y4KsZX8lTwTKIBth7ygyl.6Uu/oy3qsAoGex.Lbqi//Kd0CJK.T2y	\N	t	2026-06-28 14:10:47.758704	\N	\N
e117272a-04c6-40d8-a61c-0dae26685212	shopkeeper	Vivek Padole	vivek.padole@pds.gov	+919823030001	$2b$10$i.ShB4B.kAqKXBko4oq2a.2HcLG9TW3GlbZzDlprI6NURI0fBRRAi	\N	t	2026-06-28 14:10:47.818032	\N	\N
02ead181-7083-477a-885d-07730d20f6e7	shopkeeper	Sandeep Kale	sandeep.kale@pds.gov	+919823030002	$2b$10$PGn6Fs97WFOzZBjITPGCIedV36ohVQCoydYbjnnjOTm28znQ0cyJK	\N	t	2026-06-28 14:10:47.875866	\N	\N
642bc832-4fd9-4fa5-bcc2-281d936e6bed	shopkeeper	Mahesh Ghughe	mahesh.ghughe@pds.gov	+919823030003	$2b$10$x6lhlCxf/tOg8zvZt06Mt.72rZE.cYozx.Mo2MJ6lRiH6Bi40HtrW	\N	t	2026-06-28 14:10:47.93457	\N	\N
941aca8b-100f-4c38-af25-321d03d783c8	beneficiary	Rajesh Wankhede	\N	9604686258	\N	\N	t	2026-06-28 14:55:34.945119	Male	\N
91eadd04-0667-40f5-b257-98f0be21e518	beneficiary	Suresh Deshmukh	\N	9104332181	\N	\N	t	2026-06-28 14:55:34.992192	Male	\N
8917e2b3-42ed-4b8f-aca1-a16bcba0d90e	beneficiary	Sunita Gajbhiye	\N	9600133890	\N	\N	t	2026-06-28 14:55:35.019299	Female	\N
e984d574-8bcb-4640-aeb7-e808426bc0e8	beneficiary	Mahesh Borkar	\N	9386379402	\N	\N	t	2026-06-28 14:55:35.022874	Male	\N
849f6922-3c04-4f54-b303-03e3ab25182b	beneficiary	Anita Kale	\N	9654235116	\N	\N	t	2026-06-28 14:55:35.025852	Female	\N
00e76737-bbf7-4466-ab5e-1c6550428098	beneficiary	Vijay Padole	\N	7559407816	\N	\N	t	2026-06-28 14:55:35.02839	Male	\N
00f68a1e-8965-43ce-93af-9a455420377e	beneficiary	Meena Thakre	\N	7849593103	\N	\N	t	2026-06-28 14:55:35.035945	Female	\N
4daf03f3-8981-44b6-9209-f7e49c1e77e4	beneficiary	Ramesh Kalambe	\N	8131647525	\N	\N	t	2026-06-28 14:55:35.04064	Male	\N
048e7714-50d3-4182-8301-80ec4593b035	beneficiary	Kavita Wankhede	\N	8341928327	\N	\N	t	2026-06-28 14:55:35.043231	Female	\N
02e3af29-3f00-4c57-bb3a-62ef7253099a	beneficiary	Prakash Ghughe	\N	8483503056	\N	\N	t	2026-06-28 14:55:35.046918	Male	\N
b3a9d263-dbf7-4f66-87eb-b296177b80d1	shopkeeper	Ajay Wankhede	ajay.wankhede@pds.gov	+919823010001	$2b$10$r8vppyWc5cHDTWV04HjuluTdyEi8BP0gUXpf6MxnFkVDkbiEGK2Ka	\N	t	2026-06-28 14:10:47.414214	\N	\N
9f902a04-c282-4e4f-96b7-a9a1e44415de	admin	\N	admin@pds.gov	\N	$2b$10$WNzeWynAUqOqamJgnzUNduOvHG4rSbGBUiMNwYW9zS5yRUHw0yPYe	\N	t	2026-06-28 13:33:42.651198	\N	\N
\.


--
-- Data for Name: wallets; Type: TABLE DATA; Schema: public; Owner: himanshumire
--

COPY public.wallets (id, ration_card_id, rice_balance_kg, wheat_balance_kg, sugar_balance_kg, last_reset_date, updated_at) FROM stdin;
a80c0175-7666-4a62-ba69-aa20d975ca50	5e3d5be1-5010-40e4-a1d1-1c0660e4c73d	25.00	15.00	5.00	\N	2026-06-28 14:55:34.992192
4fc41705-e034-40b9-b4a5-d676010e5989	029dbd90-797b-47a5-9aac-ae8512059d93	9.00	6.00	1.50	\N	2026-06-28 14:55:35.019299
66f7e449-497a-49b3-9975-62fcaeafd4d3	405d8973-b424-4b61-9954-711b249b448b	42.00	48.00	6.00	\N	2026-06-28 14:55:35.022874
ded5c1c5-ee5a-4e56-825b-92bceb1a396d	8424d36a-e3ea-4e39-a8a7-f0d4292ca78f	20.00	12.00	4.00	\N	2026-06-28 14:55:35.025852
d56b02ef-33d9-4558-8e3d-f8587fa3b835	9ccdb76a-657b-42f5-a719-d406f462a349	15.00	10.00	2.50	\N	2026-06-28 14:55:35.02839
a96045e6-308b-466e-8942-9bbf2c0d5245	428780e3-e99e-49cb-9112-380c1978ac35	9.00	6.00	1.50	\N	2026-06-28 14:55:35.035945
a2eb6699-90f9-4843-8903-baab8c2997a9	3acb8cb2-2904-4304-8baf-a7a37017f986	25.00	15.00	5.00	\N	2026-06-28 14:55:35.04064
958ed3c9-83f1-4a4f-b746-626b797453a9	552b5cdd-0c24-4fac-af9b-6e088bd99f4b	12.00	8.00	2.00	\N	2026-06-28 14:55:35.043231
7e64b3f8-7013-4d7a-9119-23d7a4c9db42	30795952-ad2f-4255-9996-d52db050d9ef	42.00	48.00	6.00	\N	2026-06-28 14:55:35.046918
f1dab8e1-205e-4193-9171-9989f2d971cf	f556693d-e0fd-4c91-9d30-572eb0ebf01f	12.00	8.00	2.00	\N	2026-06-28 15:09:13.845226
\.


--
-- Name: areas areas_name_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_name_key UNIQUE (name);


--
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (id);


--
-- Name: blockchain_logs blockchain_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.blockchain_logs
    ADD CONSTRAINT blockchain_logs_pkey PRIMARY KEY (id);


--
-- Name: blockchain_logs blockchain_logs_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.blockchain_logs
    ADD CONSTRAINT blockchain_logs_transaction_id_key UNIQUE (transaction_id);


--
-- Name: family_members family_members_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_pkey PRIMARY KEY (id);


--
-- Name: family_members family_members_user_id_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_user_id_key UNIQUE (user_id);


--
-- Name: otp_verifications otp_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_pkey PRIMARY KEY (id);


--
-- Name: policies policies_category_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_category_key UNIQUE (category);


--
-- Name: policies policies_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_pkey PRIMARY KEY (id);


--
-- Name: qr_sessions qr_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.qr_sessions
    ADD CONSTRAINT qr_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: ration_cards ration_cards_card_number_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.ration_cards
    ADD CONSTRAINT ration_cards_card_number_key UNIQUE (card_number);


--
-- Name: ration_cards ration_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.ration_cards
    ADD CONSTRAINT ration_cards_pkey PRIMARY KEY (id);


--
-- Name: shops shops_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_pkey PRIMARY KEY (id);


--
-- Name: shops shops_shop_code_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_shop_code_key UNIQUE (shop_code);


--
-- Name: shops shops_shopkeeper_id_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_shopkeeper_id_key UNIQUE (shopkeeper_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_ration_card_id_key; Type: CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_ration_card_id_key UNIQUE (ration_card_id);


--
-- Name: idx_blockchain_logs_status; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_blockchain_logs_status ON public.blockchain_logs USING btree (status);


--
-- Name: idx_blockchain_logs_transaction_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_blockchain_logs_transaction_id ON public.blockchain_logs USING btree (transaction_id);


--
-- Name: idx_family_members_ration_card_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_family_members_ration_card_id ON public.family_members USING btree (ration_card_id);


--
-- Name: idx_family_members_user_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_family_members_user_id ON public.family_members USING btree (user_id);


--
-- Name: idx_otp_verifications_mobile; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_otp_verifications_mobile ON public.otp_verifications USING btree (mobile);


--
-- Name: idx_qr_sessions_expires_at; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_qr_sessions_expires_at ON public.qr_sessions USING btree (expires_at);


--
-- Name: idx_qr_sessions_ration_card_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_qr_sessions_ration_card_id ON public.qr_sessions USING btree (ration_card_id);


--
-- Name: idx_qr_sessions_shop_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_qr_sessions_shop_id ON public.qr_sessions USING btree (shop_id);


--
-- Name: idx_ration_cards_area_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_ration_cards_area_id ON public.ration_cards USING btree (area_id);


--
-- Name: idx_ration_cards_head_user_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_ration_cards_head_user_id ON public.ration_cards USING btree (head_user_id);


--
-- Name: idx_ration_cards_shop_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_ration_cards_shop_id ON public.ration_cards USING btree (shop_id);


--
-- Name: idx_shops_area_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_shops_area_id ON public.shops USING btree (area_id);


--
-- Name: idx_shops_shopkeeper_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_shops_shopkeeper_id ON public.shops USING btree (shopkeeper_id);


--
-- Name: idx_transactions_created_at; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_transactions_created_at ON public.transactions USING btree (created_at);


--
-- Name: idx_transactions_ration_card_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_transactions_ration_card_id ON public.transactions USING btree (ration_card_id);


--
-- Name: idx_transactions_shop_id; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_transactions_shop_id ON public.transactions USING btree (shop_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_mobile; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_users_mobile ON public.users USING btree (mobile);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: himanshumire
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: users trg_prevent_admin_user_delete; Type: TRIGGER; Schema: public; Owner: himanshumire
--

CREATE TRIGGER trg_prevent_admin_user_delete BEFORE DELETE ON public.users FOR EACH ROW EXECUTE FUNCTION public.prevent_admin_user_delete();


--
-- Name: blockchain_logs blockchain_logs_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.blockchain_logs
    ADD CONSTRAINT blockchain_logs_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE RESTRICT;


--
-- Name: family_members family_members_ration_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_ration_card_id_fkey FOREIGN KEY (ration_card_id) REFERENCES public.ration_cards(id) ON DELETE CASCADE;


--
-- Name: family_members family_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: qr_sessions qr_sessions_issued_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.qr_sessions
    ADD CONSTRAINT qr_sessions_issued_to_user_id_fkey FOREIGN KEY (issued_to_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: qr_sessions qr_sessions_ration_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.qr_sessions
    ADD CONSTRAINT qr_sessions_ration_card_id_fkey FOREIGN KEY (ration_card_id) REFERENCES public.ration_cards(id) ON DELETE CASCADE;


--
-- Name: qr_sessions qr_sessions_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.qr_sessions
    ADD CONSTRAINT qr_sessions_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON DELETE CASCADE;


--
-- Name: ration_cards ration_cards_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.ration_cards
    ADD CONSTRAINT ration_cards_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(id) ON DELETE RESTRICT;


--
-- Name: ration_cards ration_cards_head_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.ration_cards
    ADD CONSTRAINT ration_cards_head_user_id_fkey FOREIGN KEY (head_user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: ration_cards ration_cards_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.ration_cards
    ADD CONSTRAINT ration_cards_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON DELETE RESTRICT;


--
-- Name: shops shops_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(id) ON DELETE RESTRICT;


--
-- Name: shops shops_shopkeeper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_shopkeeper_id_fkey FOREIGN KEY (shopkeeper_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_ration_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_ration_card_id_fkey FOREIGN KEY (ration_card_id) REFERENCES public.ration_cards(id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_served_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_served_by_fkey FOREIGN KEY (served_by) REFERENCES public.users(id);


--
-- Name: transactions transactions_shop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON DELETE RESTRICT;


--
-- Name: wallets wallets_ration_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: himanshumire
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_ration_card_id_fkey FOREIGN KEY (ration_card_id) REFERENCES public.ration_cards(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict cROQrr7rcnwfP7Fa6i65FVbpHniGzTvPHRB1MSutVTbPtz9LwpnxdOWac2Clhn5

