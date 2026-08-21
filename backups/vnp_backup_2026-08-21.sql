--
-- PostgreSQL database dump
--

\restrict 9VwaOJx0SYCDeZWd4NCfr56m2Y0ZRbP9fnEJlhQ24SWXGGQaNcC7LIHOyiTCqVB

-- Dumped from database version 18.6 (3484359)
-- Dumped by pg_dump version 18.6 (Ubuntu 18.6-1.pgdg22.04+2)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content (
    id integer NOT NULL,
    organization_name text NOT NULL,
    content_type text NOT NULL,
    title text NOT NULL,
    description text,
    event_date date,
    town text,
    county text,
    mission_area text,
    source_url text,
    date_collected timestamp without time zone DEFAULT now(),
    status text DEFAULT 'active'::text,
    source_hash text,
    event_key text,
    series_key text,
    recurrence_pattern text
);


--
-- Name: content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_id_seq OWNED BY public.content.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    organization_name text NOT NULL,
    mission_statement text,
    town text,
    county text,
    mission_area text,
    website_url text,
    facebook_url text,
    instagram_url text,
    phone text,
    email text,
    donation_url text,
    volunteer_url text,
    primary_source text DEFAULT 'website'::text,
    status text DEFAULT 'active'::text,
    date_added timestamp without time zone DEFAULT now(),
    featured boolean DEFAULT false,
    last_scrape_status text,
    last_scrape_error text,
    last_scrape_at timestamp without time zone
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content ALTER COLUMN id SET DEFAULT nextval('public.content_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Data for Name: content; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content (id, organization_name, content_type, title, description, event_date, town, county, mission_area, source_url, date_collected, status, source_hash, event_key, series_key, recurrence_pattern) FROM stdin;
1235	Old Spokes Home	Fundraiser	Fall Fundo	The Fall Fundo is Old Spokes Home's annual fundraising ride supporting youth bike access programs and Everybody Bikes, which provides discounted bike sales and repairs for income-qualifying customers. Riders of all experience levels are welcome, with four supported routes of 15, 45, 70, and 100 km, followed by live music, local food and drinks.	2026-09-26	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com	2026-08-21 10:39:35.995928	active	6070ab86561dc8643d89e5ceda442b06961e7abffeb2bf70ad94903d1f5183a1	a5c68953bacaba60063a48b4e3e5a93e2589ef06ed9c4e1a322f8bd144ae5f87	a9a6962c3eddd1bdacd3a109249bf2978a4e9eb20225c9c1f77fe2c9b52889cd	\N
1236	Old Spokes Home	Volunteer	Weekly Drop-In Volunteer Nights	Old Spokes Home welcomes volunteers every Tuesday from 5–7 pm to help fix bikes, sort parts, support events, and assist with special projects. City Market members who volunteer can earn member worker credit through these drop-in sessions.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com	2026-08-21 10:39:43.798802	active	6070ab86561dc8643d89e5ceda442b06961e7abffeb2bf70ad94903d1f5183a1	65f31d264f44fbccc1a7622c3ab73a5210dae2bb4c30f78c78dbbc8a34020e9a	544c6b68e233b1a5e11d603ca15caae18d1ba6e41bb95a446fe63662b8245bf3	weekly:tuesday
1237	Old Spokes Home	Donate	Spokesperson Monthly Donor Program	Old Spokes Home invites supporters to become recurring "spokesperson" monthly donors at any dollar amount, with options to give via PayPal Giving or Venmo. This consistent support helps the Burlington-based nonprofit budget and plan through quiet winter months to keep its bike access programs running year-round.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com	2026-08-21 10:39:44.180921	active	6070ab86561dc8643d89e5ceda442b06961e7abffeb2bf70ad94903d1f5183a1	8be381ab02d49a45df7630f7c3c5fde41c5bb110f5a3891d9f69b1f8c76d77a5	4b73e6d1b6084b403b0232b508abc31473d0b8ef466b980d22c6cee472581422	\N
1238	Bellows Falls Community Bike Project	Class	Youth Open Shop	This free drop-in program runs Thursdays from 3–4:30pm year-round (except holidays) and allows youth to learn basic bicycle maintenance and repair skills on their own bikes or shop bikes. Sessions are limited to a maximum of 4 youth indoors or 6 outdoors, and children ages 10 and under must be accompanied by an adult.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-21 10:40:06.756339	active	f28bd0dd1f361af43975c03e5a6e39c81053112ffe2fa0a8a73d49177aad47ba	d76cea944f8576327f01c11256a564b447397cd3b62b08d678887c16eb8b363f	1da16add7a731541fd987a14589035f2f67b158132ba79f7e8564fbbdaf64478	weekly:thursday
1239	Bellows Falls Community Bike Project	Fundraiser	PEDALS to the PEOPLE Fundraiser Challenge	The PEDALS to the PEOPLE Fundraiser Challenge was a community fundraising effort for the Bellows Falls Community Bike Project that the organization describes as a great success. The project extends its thanks to everyone who supported the campaign.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-21 10:40:23.226415	active	f28bd0dd1f361af43975c03e5a6e39c81053112ffe2fa0a8a73d49177aad47ba	088ff83713dc6cb3d94604ab486b025c0a9fb41d39e936475b368abe0e65a1cc	2c217774c9412bcfa5d0a23922048319ac53dd2442c595b6170e5269b13d32bf	\N
1240	Bellows Falls Community Bike Project	Volunteer	The Duet Wheelchair Bike Program	This free program provides wheelchair bike rides to seniors and others who have difficulty getting out on foot, with rides currently limited to the village of Bellows Falls. Trained volunteers serve as pilots and safeties, picking up passengers at their residences, fitting them with helmets, and taking them on leisurely rides most Friday and Saturday afternoons.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-21 10:40:23.607475	active	f28bd0dd1f361af43975c03e5a6e39c81053112ffe2fa0a8a73d49177aad47ba	f028dea77dd4a61929a180597c9eb0ce20f489cd99d337d2bab9d94b2ccbac3b	990c003e46992d31d68050735d2f47a8252ea68640cdaf3da5bc7c2f52399fd2	\N
1241	Bellows Falls Community Bike Project	Volunteer	General Bike Shop Volunteering	The Bellows Falls Community Bike Project is seeking volunteers to help with cleaning bikes, parting out bikes, checking tubes, sorting parts, and replacing components at their community bike shop. Volunteers of all ages 10 and up are welcome, and hours may be applied toward community service requirements.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-21 10:40:24.015599	active	f28bd0dd1f361af43975c03e5a6e39c81053112ffe2fa0a8a73d49177aad47ba	18dbc3da2f6eae8d499d987fdbc7fca84c803ebea57410a43d5b8edc137ea22f	efc3e36bfb8abc0c1ae20bf8def20a68ee231bbfdb9b809a714d798bd589f12f	\N
1242	Bellows Falls Community Bike Project	Class	Safe Riding Youth Program	This free after-school program for grades 5–12 teaches students to navigate streets safely while riding around town, and begins in spring with a day and time to be determined. A maximum of 8 youth may participate at a time, with two adult leaders present at all times, and students may bring their own bikes and helmets or borrow them from the shop.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-21 10:40:24.397389	active	f28bd0dd1f361af43975c03e5a6e39c81053112ffe2fa0a8a73d49177aad47ba	635cb373f44e6bb01f0a3c2d33a0543a66f64d00c3d48a1cf6df462a88669e0e	cf7d2c27a527b185829f37a5ba648bab09ead718807c054ac305a31df8fa5474	\N
1243	Bellows Falls Community Bike Project	Class	Adult Repair Workshop	This workshop teaches adults basic bike maintenance and repair, either on a participant's own bike or one available at the shop, for a suggested donation of $5–10. Teens age 16 and older may attend with a parent or guardian, and the workshop begins in spring with day and time to be determined.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-21 10:40:24.778371	active	f28bd0dd1f361af43975c03e5a6e39c81053112ffe2fa0a8a73d49177aad47ba	e7ba73aafef0e0b102c310f7856aa4775c489d236b8764133af4dae51272078b	f0f25ed1e4e618536223458388c8675b52fa47110ac40a96f3f1a99a8f36e355	\N
1244	Freeride Montpelier	Volunteer	Volunteer at Freeride Montpelier	Freeride Montpelier welcomes volunteers to support the shop in roles including Bicycle Mechanic (no experience needed), Customer Assistance, Events and Workshops, Board of Directors, Organizational Support, and Fundraising. Volunteers start by scheduling an initial volunteer appointment, after which they can arrange an informal schedule with the current shop mechanic.	\N	Montpelier	Washington	Bikes & Pedestrian	https://freeridemontpelier.org	2026-08-21 10:40:48.978727	active	4caccdd29f2fa1ea9ed9cdd18a0efab31a1d956a6806500c7d0c9db9f0242d67	7d397a53908b4aca48ae29cefebfae7f4e1a733867ca10f7a8709a68d9407648	6fbc46ae7cbb7c6ba5b46e3096bde3a1ec5aebc78e666566f0b8dc6d62c4b4f9	\N
1245	Freeride Montpelier	Donate	Donate to Freeride Montpelier	Freeride Montpelier, a collectively organized nonprofit in Montpelier, Vermont, accepts donations of bikes, parts, and money to sustain its pay-what-you-can model and community bike shop mission. The organization uses a pay-it-forward option to help ensure no one is turned away for lack of funds.	\N	Montpelier	Washington	Bikes & Pedestrian	https://freeridemontpelier.org	2026-08-21 10:40:57.392931	active	4caccdd29f2fa1ea9ed9cdd18a0efab31a1d956a6806500c7d0c9db9f0242d67	df09ef36106c39e765cb94ddafa5f49e855a37665b403b2ce242334f94a28cb5	8de0a459648519eb5eaf7635981159ae0ffe8550dd4e73b7246efda363be022a	\N
1246	Freeride Montpelier	Class	DIY and DIT Bike Education Sessions	Freeride Montpelier offers hands-on bike education through DIY (do-it-yourself) and DIT (do-it-together) sessions, helping community members learn how to fix and maintain their bikes for each season. Sessions use sliding-scale pricing and no one is turned away for lack of funds.	\N	Montpelier	Washington	Bikes & Pedestrian	https://freeridemontpelier.org	2026-08-21 10:40:57.774238	active	4caccdd29f2fa1ea9ed9cdd18a0efab31a1d956a6806500c7d0c9db9f0242d67	3c573f0eded8f6d783df00c3c448a7dfe8fb1e573d9e6a8b16e14307e3cc4d7f	6713af92ce440fdf8a84ad902511460e51f2d4fccb4de23d17ae84fac900ff04	\N
1247	Green Mountain Foster Bikes	Volunteer	Foster Bike Rebuild Volunteer Program	Green Mountain Foster Bikes invites volunteers to learn how to rebuild donated bicycles into single-speed coaster brake bikes for Vermont foster children. Volunteers work alongside founder Timothy Mathewson, a 40-year bicycle mechanic, and can contact the organization directly to get involved.	\N	Middlesex	Washington	Bikes & Pedestrian	https://www.greenmountainfosterbikes.org	2026-08-21 10:40:59.162795	active	002707a40d66be98fa928f626ebead561cddad8e58e72b3f9dda7c8f207858ef	5bb17e74d7d8b1e73309e064d07c3d59d202c8838adfe2c6b80cd89086f48958	afeb4c9fc8aece8e71319b9af4f89afca8de36c6d2ce29d2c28c064f3452d4f1	\N
1248	Bennington Bike Hub	Event	Community Ride: Family Ride	The Bennington Bike Hub invites families to meet at the Bennington Firehouse parking lot for a short, family-friendly ride to Willow Park. Kids, tag-a-longs, and trailers are welcome on this community ride.	2026-08-23	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:11.029609	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	5745fba1d35678728c04bf98ecc3acbf5197d416dfbc36e79ad51e80b99a50fe	8e341950682f44147656aac547890d9abbd76aca4d4588d718261da741a476fc	\N
1249	Bennington Bike Hub	Event	Our Gravel Ride '26	The Bennington Bike Hub is hosting its annual gravel ride on September 12th, departing at 9am from the shop. This year's ride follows up on last year's chilly November edition of Our Gravel Ride '25, with hopes for better weather.	2026-09-12	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:31.219734	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	a73d56c5cafa49c6b2f9ba41682d2ae6aba8bea6abd3ccbafb72cdda398a0c2f	7949960d0b0832105d1924db66ebf08e2949963e46e3a5f4aec2512d2a4e572f	\N
1250	Bennington Bike Hub	Volunteer	Thursday Volunteer Nights & Open Stand Time	Every Thursday from 6–8pm, the Bennington Bike Hub hosts after-hours volunteer time where participants can work with other volunteers, use the open stand to work on their own bike, or develop technical repair and retail operations skills. No RSVP is needed — just drop by, and pizza and refreshments will be provided.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:31.600382	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	8a040eec2bf8d54a989793d05a7c6c69fa5aad97c60e49497a8e7c0167f19488	9073d7db207e596f6afa36aa59f17843611c99c54a61523359a76075f537809d	weekly:thursday
1251	Bennington Bike Hub	Volunteer	Ride Leaders Needed for 2026	The Bennington Bike Hub is seeking volunteer ride leaders to coordinate and lead group bike rides as part of its community programming for 2026. Interested volunteers can contact jess.rice@ourbikehub.org to get involved.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:31.981577	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	f667e7d330fb92a2a40dfbdf19919b654585975f97fa04bb625c3d3a092000cc	d7d8559e552f3335042284fe77a8cd89c28c9f8e795c271c36cc73b93e6c984d	\N
1252	Bennington Bike Hub	Event	Tuesday Night Rides	The Bennington Bike Hub hosts Tuesday Night Rides every Tuesday at 5:30pm departing from the shop, a program that started April 7, 2026. The rides are described as a chill mix of quiet paved roads open to all cyclists.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:32.364029	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	e9549362876466acd06da0f2820b23c0ad10129f8d17b71e55bb64765eaa1adc	dfeaa6c341b04e64ad8482697683e46211a810a5d42a749f32e5e4b3064ab433	weekly:tuesday
1253	Bennington Bike Hub	Class	Earn-a-Bike Program	The Bennington Bike Hub offers an Earn-a-Bike program aimed at young volunteers, referred to as Bike Angels, as part of its youth empowerment mission. The program is part of the Hub's broader effort to teach youth bike repair, problem solving, and leadership skills.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:32.745343	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	41886ad45ae1234837e9e81de6210d8305d8c3184c6d7312e141973068ec51e1	2a5d6de97e81aa0c3a05445946095e813232e4ecde2dbfbc36c7231b322298a7	\N
1254	Bennington Bike Hub	News	Green Mountain Power E-Bike Rebate	Green Mountain Power customers can now save $200 when purchasing a new e-bike for their commute through a rebate program supported by the Bennington Bike Hub. The Bike Hub is highlighting this incentive as part of its mission to make cycling accessible and affordable for Vermont residents.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-21 10:41:33.125824	active	7905bce841ecf10c8b66fba176f08b8e0133f79e6a4ce06b4b4f3edbdd7d3c53	3d7fd7c3f5c165891a11cb7d6764fa26c4022d9de2066307b3eaa7df5c7402bb	16b48a92e55f3d6c157b6ace5b1bf735b8496fbdca397852fa210cb1cf333402	\N
1255	Bettys Bikes	Event	Frame Fest	Frame Fest - see event page for details.	2026-09-06	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org/event/2644/	2026-08-21 10:41:51.724406	active	444ba39080d5253c30fd9e302c56003dfd3a4da6a0028509a0ae49609e9f02da	a838dc0e777f95ac0884d5ba89b5a92540c17cb9886304b295faec06dce28b24	d53a997571d4e4037932b3dfdcffb835626a23689cf8c0cd234cfc8055a2e360	\N
1256	Bettys Bikes	Class	Bicycle Mechanic Apprenticeship	Betty's Bikes offers a two-to-four month bicycle mechanic apprenticeship program held one to two days per week, with afternoon sessions from 1–6:30 on Monday, Wednesday, or Saturday. The program includes hands-on instruction, supervised work, and an immersion session, with a sliding scale tuition of $1,200–$2,500 and partial work-trade financial aid available.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org	2026-08-21 10:42:01.432479	active	444ba39080d5253c30fd9e302c56003dfd3a4da6a0028509a0ae49609e9f02da	e9b90ab48c54f82e45890887f518b26b15bce72880c052c1df451dc4f3751cc7	b98a79e7a24c40009ff72d9b991be245aee9ee215449472267d5a8352f43bd4c	\N
1257	Bettys Bikes	Event	Potluck Dinner	Betty's Bikes hosts a community potluck dinner most Sunday evenings from 5 to 7:30. The recurring gathering is listed on the shop's community calendar as a regular weekly event.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org	2026-08-21 10:42:01.814101	active	444ba39080d5253c30fd9e302c56003dfd3a4da6a0028509a0ae49609e9f02da	63dca593c1c7c1b2184b83afa0805f30e5bb03bbc2b7a6588e4287c34af0a18f	94d6df99872e8d8aa0c345ea2ab93d1ca0a8e12f51faa29c7803eadc1143b77a	weekly:sunday
1258	Vermont Mountain Bike Association	Event	VTYC - Race #1: Ascutney Outdoors XC	VTYC - Race #1: Ascutney Outdoors XC - see event page for details.	2026-08-22	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/vtyc-race-1-ascutney-outdoors-xc-2/	2026-08-21 10:42:20.936326	active	2793ba2b97f204b33f5fa3d3a34d48df3b604c0b7ee89867ed45a6d9363e8d99	34df67056d3ab1644251508f6149b96799d6b8cf6553b30dc9f0de4a6c284408	71122e07b8d46620b64a1ccf59046dc7f066a52f057cfe73809bff3e5b101d05	\N
1259	Vermont Mountain Bike Association	Event	WAMBA - Triple Crown Throwdown	The 2nd Annual Triple Crown Throwdown returns bigger and better than ever! Come experience the best of riding in the Woodstock Area with a race across all three WAMBA networks. More info will be posted this spring. Registration and details will be posted here:  https://www.bikereg.com/73579#Notes	2026-08-23	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/wamba-triple-crown-throwdown/	2026-08-21 10:42:21.318226	active	2793ba2b97f204b33f5fa3d3a34d48df3b604c0b7ee89867ed45a6d9363e8d99	a5595d6d811d65350ebaaabaed1498f3ffbf49cf298df6b85a7d80269c566d6b	3f8dcb4dc89a1ad4e3accb9acaac7edaeed77632d228e9c585ba3541ca4ee6ee	\N
1265	Kelly Brush Foundation	Event	Best Day Ever: Burke	Join Us in Burke, VT, for Best Day Ever Screening Tuesday, September 29 Location TBD Documentary film Best Day Ever follows KBF’s Chief Program Ambassador Greg Durso and community member Allie Bianchi as they tackle the daily challenges of disability and find joy, connections, and belonging in Vermont’s mountain biking community. The film won the Audience Choice Award for Overall Documentary at its October premiere at the Heartland International Film Festival in Indianapolis.  Since that initial	2026-09-29	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/best-day-ever-burke/	2026-08-21 10:42:27.059896	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	f576faf38f8b7e4e51160dca9da5b063f9776a0bf2f75737123d8d4ae153c73f	8a894b133129097370acf060a8456622e5794cfc1b3e141e899d344529004afe	\N
1266	Kelly Brush Foundation	Event	Adaptive Rec Talks - Archery	This week’s discussion: Archery  September 29 at 5:30 pm  Join us for Adaptive Rec Talks, every other Tuesday at 5:30 pm, for a vibrant and inclusive discussion group on Zoom focused on adaptive sports and recreational activities.  Hosted by the Kelly Brush Foundation in collaboration with the United Spinal Association, this group provides a platform for adaptive sports enthusiasts to engage in lively discussions about various recreational activities. To enrich our conversations, you might hear 	2026-09-29	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/adaptive-rec-talks-archery/	2026-08-21 10:42:27.4414	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	8ab7a87795bbdc4ec9aa35fa76318e12ed2fc5a7305017727f9262a7d801e795	dbc7a6fb9ba49bf63c95814b976270e7b1f32957f3f101bc31f59b3dbf97e7ab	\N
1261	Vermont Mountain Bike Association	Event	2026 Delta Dental Race To The Top Of Vermont	RACE TO THE TOP OF VERMONT  Join us for the 2026 Delta Dental Race To The Top Of Vermont on August 30th in Stowe! This year marks the 20th Anniversary of Race To The Top, our annual fundraiser for the Catamount Trail Association.   Bring your friends and family and join us for a run, bike, or hike up the historic Mansfield Toll Road – 4.3 miles in length and 2,564 feet of up. It might not be easy, but Race To The Top is for EVERYONE!    Kids Fun Run at Noon (ages 4-14) Post-race meal, beverage t	2026-08-30	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/2026-delta-dental-race-to-the-top-of-vermont/	2026-08-21 10:42:22.518833	active	2793ba2b97f204b33f5fa3d3a34d48df3b604c0b7ee89867ed45a6d9363e8d99	321aeba020eff99e50439285a08acd68dc3f09c2cb7ba2a1b165a8bf65e51292	a40da775738133629b518070fad4445f8b244fd4a12a5cccabcba3e03616391a	\N
1260	Vermont Mountain Bike Association	Event	Stowe Trails Partnership S&A Trail Work Night	Join Stowe Trails Partnership every Monday evening to help build Stowe’s first directional double black trail- Serenity and Adrenaline! Meet here at 5:30 on Mondays to head up to trail that is filled with rock rolls, drops, and other natural features galore.  What to bring: Closed toed shoes Water Your favorite tool (if you have one) Work gloves Bug spray  What we’ll bring: Tools glore Alchemist Beer for post-building.	2026-08-31	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/stowe-trails-partnership-sa-trail-work-night-14/	2026-08-21 10:42:21.701326	active	2793ba2b97f204b33f5fa3d3a34d48df3b604c0b7ee89867ed45a6d9363e8d99	0dcf95a2a49a1ba975339fdba23ee547b8354455f5c03a7342096f191981d6eb	8f162b391e0b6bf1665de774f5a5d8fc2a013c64720479a2966c750057d8299e	\N
1262	Kelly Brush Foundation	Event	Adaptive Rec Talks - Tennis	This week’s discussion: Tennis  September 1 at 5:30 pm  Join us for Adaptive Rec Talks, every other Tuesday at 5:30 pm, for a vibrant and inclusive discussion group on Zoom focused on adaptive sports and recreational activities.  Hosted by the Kelly Brush Foundation in collaboration with the United Spinal Association, this group provides a platform for adaptive sports enthusiasts to engage in lively discussions about various recreational activities. To enrich our conversations, you might hear fr	2026-09-01	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/adaptive-rec-talks-tennis/	2026-08-21 10:42:25.916483	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	ddccabc706f49b67d944f8120d4eee8aa09fabccaee1107e79dd89e5c578035d	bc9a644702cbbe867e4c9d9ea89b0c2df4bb9aca4cea842d60b91f4395c644f9	\N
1263	Kelly Brush Foundation	Event	21st Annual Kelly Brush Ride: Vermont	Join Us for the 21st Annual Kelly Brush Ride powered by Union Mutual! Saturday, September 12 Middlebury, Vermont, or Remotely Join us for an exhilarating day cycling the beautiful Vermont countryside to support the Kelly Brush Foundation’s mission to inspire and empower people with spinal cord injuries to lead active and engaged lives.  Choose to ride the 10, 20, 50, or 100-mile road routes, or the 30-mile unsupported gravel route. Whether you’re a seasoned cyclist or just love a good ride, this	2026-09-12	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/21-annual-kelly-brush-ride-vermont-2/	2026-08-21 10:42:26.296049	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	7918c163543754f0f8ae7cb97d12e4a2f567bca8a6690d843fe32e9c025f7ba3	5f44f01ee0238d9dfad73d6c2063f55e60456caee3eefce3d0cca3118bba6073	\N
1264	Kelly Brush Foundation	Event	Adaptive Rec Talks - Pickleball	This week’s discussion: Pickleball  September 15 at 5:30 pm  Join us for Adaptive Rec Talks, every other Tuesday at 5:30 pm, for a vibrant and inclusive discussion group on Zoom focused on adaptive sports and recreational activities.  Hosted by the Kelly Brush Foundation in collaboration with the United Spinal Association, this group provides a platform for adaptive sports enthusiasts to engage in lively discussions about various recreational activities. To enrich our conversations, you might he	2026-09-15	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/adaptive-rec-talks-pickleball/	2026-08-21 10:42:26.678308	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	8f733b6788c55dc7a74f3359ea77a46ddc607cdedeff6a9c3273b899d1f9e7e4	68feb286f28ed2fe79c318a4985e7435f947fe5e58985b56c121f4b2cdaf51b1	\N
1267	Kelly Brush Foundation	Event	aMTB Camp Downhill Day	aMTB Camp Downhill Day October 1, 2026 Burke Mountain, East Burke, Vermont Due to resource limitations, attendance is by pre-registration and invite only. Submit your information for consideration. We will reach out pending space to include as many community members as possible.	2026-10-01	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/mtb-camp-downhill-day/	2026-08-21 10:42:27.822985	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	657dc4a65bd02e4325439505ef56527319f22abc4a3d9239db2d25e8b37c2c8b	bb57598100c4d2ed3d9a542bcc690049c32a500f65443997f1332f8f9217eaa5	\N
1268	Kelly Brush Foundation	Event	Adaptive Rec Talks - Fencing	This week’s discussion: Fencing  October 13 at 5:30 pm  Join us for Adaptive Rec Talks, every other Tuesday at 5:30 pm, for a vibrant and inclusive discussion group on Zoom focused on adaptive sports and recreational activities.  Hosted by the Kelly Brush Foundation in collaboration with the United Spinal Association, this group provides a platform for adaptive sports enthusiasts to engage in lively discussions about various recreational activities. To enrich our conversations, you might hear fr	2026-10-13	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/adaptive-rec-talks-fencing/	2026-08-21 10:42:28.203584	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	18f7ed3aff1676cb82c7eb637119a7c3a79eb7af839b3a4bfb149445c2e4507f	906b287015338b7cb2dcf9d47a19712b73455be250e7b4f298c5d8f062525338	\N
1269	Kelly Brush Foundation	Event	Adaptive Rec Talks - Rowing	This week’s discussion: Rowing  October 27 at 5:30 pm  Join us for Adaptive Rec Talks, every other Tuesday at 5:30 pm, for a vibrant and inclusive discussion group on Zoom focused on adaptive sports and recreational activities.  Hosted by the Kelly Brush Foundation in collaboration with the United Spinal Association, this group provides a platform for adaptive sports enthusiasts to engage in lively discussions about various recreational activities. To enrich our conversations, you might hear fro	2026-10-27	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/adaptive-rec-talks-rowing/	2026-08-21 10:42:28.586087	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	6ecc5c16f054e05792deb0578e5a45d2d11583660fc31c750a08068a63f8db3b	47a9196ab1ca25715dceaa12d55988042388336d3e044af499ed60b9239c9115	\N
1270	Kelly Brush Foundation	Event	Killington World Cup Weekend	Killington World Cup Weekend November 27-29, 2026 Killington Ski Resort, Killington, Vermont More information coming soon! Stay tuned.	2026-11-27	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/killington-world-cup-weekend/	2026-08-21 10:42:28.966679	active	87388e6a55de4cb9da4f371a61fb5d7581a736ee4b299c1b54d0d101dec26881	f23ae2a2d5918cfdf374b1565c6aef1ac6826a8fa117bc4d270ca35753d7f9a8	7173807e48c06199345e2fb7f54de49429a12629b2411c8e8d5fedde73f6839d	\N
1271	Pride Rides VT	Volunteer	Volunteer Ride Support for Pride Rides Events	Pride Rides seeks volunteers to support group rides, including experienced cyclists who can sweep rides by staying at the back of the group to ensure no rider is left behind or in trouble. Those with wilderness first aid experience or certifications are also encouraged to participate and make their skills known at events.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	2026-08-21 10:42:41.557036	active	03640efd2991f85f2c05a0fac8f6dc04f98f558f6d415be4b0e4b923ff2eb759	c7d18ad136d9c963a90b65447152a1f329c360ef6a9b043980c6d7b0bf3c81e5	032465d831d4a0e7f9dfc792422cc67bfbe43ceb9426e6e9fd9ab36690dc0f71	\N
1272	Pride Rides VT	Donate	Support and Donate to Pride Rides	Pride Rides accepts financial contributions as well as usable equipment donations including bicycle helmets from independent bicycle retailers and bicycles in good working order sourced from an independent bicycle dealer within the past five years. Monetary donations and equipment can be directed through Pride Rides directly or through Vermont Bicycle Shop, whose owner Darren Ohl serves as an ally partner.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	2026-08-21 10:43:24.458271	active	03640efd2991f85f2c05a0fac8f6dc04f98f558f6d415be4b0e4b923ff2eb759	429ccdce515ab1078c9b66fc58f2f851fa1117c64a0caf6ce18ac69bc908a2ea	bfb2b27c420346f9f1c3932591c6e5a243d28df0c1f6f2e0ae9d61a00b32ff30	\N
1273	Pride Rides VT	Fundraiser	Pride Rides VMBA Community Builder Membership Add-On	Pride Rides encourages supporters to add Pride Rides as a Community Builder add-on when purchasing an annual Vermont Mountain Bike Association membership, which costs $30 and helps demonstrate to VMBA that Pride Rides deserves representation at a broader table. Choosing this option supports Pride Rides financially while also bringing LGBTQIA+ visibility to the larger Vermont mountain biking community.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	2026-08-21 10:43:24.839315	active	03640efd2991f85f2c05a0fac8f6dc04f98f558f6d415be4b0e4b923ff2eb759	9d80f9e2b6d6273c4435554789d7810076a697132cc9a1e9c63523de5f1dbd7f	e82d51902e1c62373b41c7b86e214646f0f2497540e95f785ed67a3fc11c5984	\N
1274	Pride Rides VT	News	Gear Library	Pride Rides maintains a gear library as part of its effort to reduce barriers to cycling for LGBTQIA+ individuals, who statistically face higher rates of economic hardship than their cisgender heterosexual counterparts. The organization collects and maintains a fleet of bicycles so that any rider who needs one can participate in Pride Rides events.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	2026-08-21 10:43:25.221719	active	03640efd2991f85f2c05a0fac8f6dc04f98f558f6d415be4b0e4b923ff2eb759	0e4cfdd82be40245946c08570939f8d1503ff8b3902471582335daee31c36391	2b9c571af4c72c8527a7dd9a1667bbf6532313a0a58f39e9340cdbc83f521449	\N
1275	Pride Rides VT	News	Mindful Identity	Pride Rides published a detailed explanation of its organizational iconography, describing the meaning behind its logo which combines a pink triangle — reappropriated from its Nazi-era origins by queer activists like Avrum Finkelstein — with a bicycle wheel whose colors represent the pride flag and whose knobby tread honors founder Kris Hunt, who is Trans and an avid mountain biker. The Vermont state outline at the center of the icon is rendered in black and white stripes to represent the complicated nature of ally-ship from the state where Pride Rides was founded.	2026-02-11	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	2026-08-21 10:43:25.602987	active	03640efd2991f85f2c05a0fac8f6dc04f98f558f6d415be4b0e4b923ff2eb759	29f40f97e390d885ec484d5d15fad33930bf8508afd936534a859f3c43cc032e	6ba536c5583420c9c17a5b01b798fa56f68b9f1f48213370ac871b726e2d14f5	\N
1276	Pride Rides VT	News	Why Pride Rides Exists	Pride Rides published a foundational statement explaining that the organization began in 2018 when founder Kris Hunt hosted the first Pride Ride in Barre, VT, and became a nonprofit in 2020 with a mission to create diversity, inclusion, and representation of LGBTQIA+ people in cycling. The organization addresses economic barriers by collaborating with allies, local shops, and trail networks to provide bike rentals, waive trail fees, and maintain a fleet of bicycles for riders who need them.	2025-04-28	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	2026-08-21 10:43:25.984415	active	03640efd2991f85f2c05a0fac8f6dc04f98f558f6d415be4b0e4b923ff2eb759	fb204bde2ce5a35dae6026fefd2a44a5b0a7cc032699278bc380c83fa80478f5	8739fc7722b8bc4f0e384058d8b05cbbc4b98f20cba46a896560aa563384432b	\N
1277	Local Motion	Event	E-Bike Demos & Valet Bike Parking at Burlington Electric Department Net Zero Fest	Local Motion will offer e-bike demos and valet bike parking at the Burlington Electric Department Net Zero Fest in Burlington, Vermont on August 22. The event is part of a series of biking and rolling community events Local Motion has organized or participated in across Vermont this August.	2026-08-22	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02CBteW81RbA6rHc7y5dTvNETav7qE9xHboWBjpBnW1yQULYTKtXsvFGqz44QazWgl	2026-08-21 10:43:47.749279	active	ab4593ae50407523dee2709736a97cde6ad950d41f56bd0397d454fd9eada1f2	331cbad83105c8d5d059bd608bf3922bb0d5df1b340e60f10012e4b80e86822d	71251f79886b8a30a1996a88ce81a61c68e6e3a6c099a1b876891fe411eefa51	\N
1278	Local Motion	Event	Bike-In Movie Night at Old Spokes Home showing Best Day Ever	Old Spokes Home in Burlington, Vermont is hosting a Bike-In Movie Night screening of the film *Best Day Ever* on August 23. The event is among the biking, walking, and rolling community events Local Motion has highlighted for Vermont residents this August.	2026-08-23	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02CBteW81RbA6rHc7y5dTvNETav7qE9xHboWBjpBnW1yQULYTKtXsvFGqz44QazWgl	2026-08-21 10:44:04.163965	active	ab4593ae50407523dee2709736a97cde6ad950d41f56bd0397d454fd9eada1f2	55621e6200f8c717c044857450a3c566321e252680867792028f0671f7cc3f73	a6e19af3d620b6d19ff967aecf1dcd03e7ac6e89823b7a1f8531ddb0902df288	\N
1279	Local Motion	Employment	Bike Rental Shop Part-Time Staff	Local Motion is hiring part-time employees to work at their bike rental shop on the Burlington waterfront, with responsibilities including greeting customers, processing reservations, and fitting customers to bikes. Shifts are 5–6 hours long, either mornings or afternoons, seven days a week through the end of October, with pay starting at $15–$18 per hour depending on experience.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0fgtYSEAA3qjP4SJuCAU1WMv58TUzqW45kuJvdF4EpPNQ9K5tPyNxBnPL3YNTNCfAl	2026-08-21 10:44:07.109734	active	30a7cabf2cb81b566b5cdb9b08f1c884dc4676fb01553626164e085ef5b8e6b3	c05c8edcd2bf443fa23b7a34aef1b174e55fd7eb40fea95242093dc0f3dd872c	bd3bf53b5eb882ee3e3fd923af8c3b2d308fb1c03064648e8e593e0e7fd69117	\N
1280	Local Motion	News	Bike Ferry Closure for Maintenance	The Bike Ferry will be closed on Tuesday, August 11th while maintenance is performed on the boat. The Island Line Trail will remain open during this time.	2026-08-11	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02PvN1Ms7GTANLkU8Nv4mbgDCQW3HZfUhzFCg1wFHXY1TCidhGi5pgqAu9aPRqnk4Nl	2026-08-21 10:44:09.755513	active	d01b662701cafcaaf1ffd97d8028072e11ae30789e05e503aa560093faaa88f2	ea7b67cf9dddbb3ab1ba71df79164c0577316f0f5cd6dd37212893dde36d66ab	264a7ee532a501df8f671e06c781f6dbab7bca075c259f3ab44080764cdedd26	\N
1281	Local Motion	News	Burlington Bicycle Friendly Community Survey	The City of Burlington has applied for Bicycle Friendly Community status from the League of American Bicyclists and is seeking input from local residents. Anyone who lives, works, commutes, or recreates in Burlington is invited to complete a brief survey to help provide a better understanding of local bicyclists' experiences.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02fvebCYMbbHcxWG74aLUkB32RQYFTc36Qvb4jeRRgg3ins6F8VMF1VHQJUnc293Rzl	2026-08-21 10:44:17.847927	active	5c977b303cc7ac8f87c73c44d1a18e78de8f2f6dffdfd03392303ffa6203b956	88e78d89809e5c036d8ab95bbc2c0ffe68da93244b688518170e41511db964aa	cf660d971eca26d529f04fce356663d43847bbfa75c6a58da9aa3c6a376f2b0c	\N
1282	Local Motion	Event	Little Lake Lessons	Little Lake Lessons is a weekly summer program at the end of the Causeway where Lake Champlain Sea Grant staff or local partners share knowledge about Lake Champlain with visitors waiting for the Bike Ferry. Topics cover the lake's natural and cultural history, geology, ecology, challenges, and recreational and stewardship opportunities, brought to you by Local Motion, Lake Champlain Sea Grant, UVM, and other partners.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0GK9xJJswGStW3rMEHw53ShF5bG3Pry32HgvZuQxVpyk65Ge8TP25AHS9np9dtKZ3l	2026-08-21 10:44:26.311468	active	8a5c4eab5a60dca6092cabd282738310dfc780c5c59dc2079b145226bb65102b	2afa01a93a50663aaa6952c77fd7d7eeb9aa0a0882af8108f228d132b054e829	5d88731a6a1d184000b797f91ea38e13f26b716a64a9d6053f3b2b832a4be566	weekly:thursday
1283	Local Motion	News	Valet Bike Parking Unavailable at Waterfront Concerts in Burlington	Local Motion has announced that Valet Bike Parking will not be available this year for the Waterfront Concerts in Burlington, running from July 30 through August 2. This is a change from prior years for attendees who may have planned to use this service when biking to the Burlington waterfront event.	2026-07-30	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02GtTpauB2zLgeJHeGhfSkv1cL8HpqrwmV1KDUVpmDRTLjcbmYBSLZ5LW736EqCVS8l	2026-08-21 10:44:32.768077	active	a8165042156de8726725ff6ef2ab5a8fc6a7871db418ea215bc2d708c4a56024	980eb4560ecd0ea178f2ac621e8a84064e9adbe514fc6379d876337d547d3587	42d1621969710d6132e15690035f0fc6dd4d63f6bdccc6f963aba3e2e9082ad6	\N
1284	Local Motion	Fundraiser	Local Motion Summer Appeal Raffle	Local Motion's Summer Appeal gives donors the chance to win a bicycle trip for two to Spain with VBT/Country Walkers, along with other prizes. Each raffle entry costs $10, and through August 31, donors receive a bonus entry for every $60 donated.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0iDEMPoWA4m7pApksZCb22VEN6xv3wnT5RWLLbkX9RUaYXv1CpFkzJTHhVC8Gf9xyl	2026-08-21 10:44:35.836959	active	6ad9c63cad3fab6c2408c0ac0a598f5d499130d8bb6292fcee1de7be05244faa	343a2c87d95d82def417a730aa31bc0a6284d9e19dd8569f1fde78c4b6dbd95c	8c446cbda22ebfb3f537f1f463f76f5c90bcb0405e76535d52fbc04b66166951	\N
1285	Pride Rides VT	Event	Annual Bikepacking Adventure with Vermont Bicycle Shop	Pride Rides VT and Vermont Bicycle Shop are hosting a multi-day bikepacking trip starting from the shop in downtown Barre, traveling over to Plainfield and down the rail trail to Ricker Pond campground in Groton State Forest. The trip includes an overnight stay in a pre-reserved lean-to or cabin, with a full day of bike adventures, campfires, swimming, and relaxation before returning to Barre via the same route.	2026-09-05	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0j3cPyarKLHBexsH8CmPtv7ow62Df4K6WCFEZh86kkeSBHh4j9c9qopcan5ibchGcl	2026-08-21 10:45:24.74513	active	dfed31cf6300851fb406cb6c520661049d977fd89902df9d2997ec4038603464	e4121441d28fd4a915271d58dba69501545e73f742398d1beb70086dd02f38d9	e1685d9822d3ef58e0265aaf0db29e27df55a9cad23b7c8e911b04955f28e433	\N
1286	Pride Rides VT	Event	Bikepacking Adventure Informational Meeting	An in-person informational meeting will be held at Vermont Bicycle Shop on August 25th at 5:30pm for those interested in the upcoming bikepacking adventure. Attendees can learn details about the trip, which runs from downtown Barre to Ricker Pond campground in Groton State Forest.	2026-08-25	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0j3cPyarKLHBexsH8CmPtv7ow62Df4K6WCFEZh86kkeSBHh4j9c9qopcan5ibchGcl	2026-08-21 10:45:31.57898	active	dfed31cf6300851fb406cb6c520661049d977fd89902df9d2997ec4038603464	3569926657ffa04e6fa5e4de21638af3083067ed25a70dd2289f5668cb4db7a0	faf7ab6383b9193d4ced13bc87986c062a11235e879baf3528a659deaafa58eb	\N
1287	Pride Rides VT	Event	Gravel Group Ride at Queer Arts Fest (Sunday Morning)	Ride leader Harlow will host a family-friendly, all-levels gravel group ride at 9:30am at the Queer Arts Festival on Little John Road in Websterville, VT, covering approximately 3 miles. Bikes and helmets are available to borrow in advance through the Pride Rides VT gear library, and helmets are required for participation.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0pHyoHewJY47s3bvio5fr3f7YUcTP8FdtNzYWRiNUyySRgR5QTSaGoGFNmvxAZhobl	2026-08-21 10:45:46.719651	active	51d180b5a2e0ed8f74d61c05119a17de0a31654a501c9f6a50bf3e038ac57ad8	6739dd5a6ff48ef6889ca1cfc1d67527d9a4bf3c415725a26ca957e2dc166233	7b189631df0d85482063663d09b1793bc17faa156fcc4b2eb66c126a0aaec48e	\N
1288	Pride Rides VT	Event	Pride Ride at New Leaf Trails in Bristol	Pride Rides VT is hosting its first-ever Pride Ride in the Addison County area at Addison County Bike Club's New Leaf trails in Bristol, Vermont, with a 5PM mountain bike ride lasting approximately 1.5 hours. Following the ride, participants are invited to a creemee social at Holy Halvah, and riders should bring their mountain bike, water, and money for post-ride creemees.	2026-08-21	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid02kBMWxNJUn4FuomTA8SMmRFxZjpw17LGzfmrBSYWLjJST1xcN5DcKWekR3RMKYaqFl	2026-08-21 10:45:55.754724	active	1dceae2a0e7d1a62cb53bda8069c195326ceb79bcb005e7b44d908bc199fb851	095f8e8696429e4f4ef65ef03d35f41060fa9b08c5bc0e685d22ba14ee2c464f	7c9940c68afbe1eef11e90ddd2b2a2ea8d80726569dd4028235c201d10acd3e7	\N
1289	Pride Rides VT	Event	Cady Hill Trails Morning Group Ride and Lunch Social	Pride Rides VT is hosting a mountain bike group ride at Cady Hill trails (311 Mountain Rd, Stowe, VT), part of the Stowe Trails Partnership network, meeting at 10:15am with ride time starting at 10:30am. The ride covers approximately 4-7 miles of trail over 1.5-2 hours, is open to all levels including beginners, and will be followed by a lunch social at Ranch Camp Stowe.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid037SE9SHWF9BZBUTCKVHp4TPBhD2pqw66vnSHDMkLBYFvjE8cM9FWkE6vC71YG6chjl	2026-08-21 10:46:03.901631	active	d239521074903c3c4235bf482cd88f79356a1d49d54cf7f8f84c221efc7c51ca	e31b6046980bb27cae30c798a08b89934ff1e734a5cab2713aa953d9605c37d4	54f8a911e337cf828dfccfb4f327d0b3e1344f878189a96e7e93e37304d7e972	\N
1290	Pride Rides VT	Event	Mountain Bike Group Ride at Millstone Trails	Pride Rides VT is hosting a mountain bike group ride at Millstone Trails in Barre, starting at 5:30pm meet-up and 5:45pm ride time at the parking lot for Barre Town Forest at 44 Brook Street, Websterville, VT. The ride covers approximately 4.5–6 miles of rocky and rooty high beginner/intermediate trails over 1.5–2 hours, with optional technical features to try along the way.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0izt3QWyx7xeSVLHUxfiUiYTcwMQWwn4yBzmfpExx58xsTrkJXyDkRfYSRfqtW8Wil	2026-08-21 10:46:12.380597	active	c4faa3efcf3b711bbc2b291bd121b0d3674d033c925d79a127bf27df71d475d5	f499a470afff55873790ecd6a31924803d309cda5a4269700dced80471a3508c	2e878d9b206b61d0a3a398cc97bb9c0ce304a3c53a9d7863fb236419746d7997	\N
1291	Pride Rides VT	Event	Barre Pride Ride	Pride Rides VT will lead a group ride around Barre to the Barre Pride festivities, with pizza available at the event. The ride is scheduled for the weekend following the postponed Blueberry Lake ride.	2026-08-29	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0dggy8b7xGCuvAuMFAy4kdCnvQzSzkUnzYPsrZqxrDYeF5AJcMbkFWBP1uYzuySzzl	2026-08-21 10:46:27.093522	active	6f6a2afe44ca6c0daa8b565d167f6ef03d0df1685de3de689b43b44fdbe79a63	28c0459905208b3daad13622349e39ea069b873933c4385f1cd1b6be3c5ab12c	eb398fc3392fbf5956038f6ee058f08caa9f148c9b151f9552d6669372e1a047	\N
1292	Pride Rides VT	Event	Essex Pride Tabling	A couple of Pride Rides VT members will be tabling at Essex Pride in Essex, Vermont, happening rain or shine. The event takes place the day after the postponed Blueberry Lake ride.	2026-08-22	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0dggy8b7xGCuvAuMFAy4kdCnvQzSzkUnzYPsrZqxrDYeF5AJcMbkFWBP1uYzuySzzl	2026-08-21 10:46:27.473212	active	6f6a2afe44ca6c0daa8b565d167f6ef03d0df1685de3de689b43b44fdbe79a63	95eed24d191e9baf80c11ecdf5557ff722da047550f5d0ede0e158983966685a	e2f72dc49e511cb3b1887e110027098adaabc1563b7307e25241d5800ae940a7	\N
1293	Pride Rides VT	News	Pride Rides VT Pamphlet Distribution Tour	Pride Rides VT is touring around Vermont starting Saturday, August 22, visiting bike shops, trail centers, queer spots, and other community locations to share information about the organization. New pamphlets designed by Caroline P and printed by CW Print Design will be distributed at stops throughout the state.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid02sM7mHvaV5Zehv4xMjhSccrPoRyLEQNarnNvT93DLjySo5GXikea1MBSciiZgnqLxl	2026-08-21 10:46:39.946874	active	75b3657889b0d15f9e5d1c8fd6601d5f6a1fba2fbd910e4fb714c60b0097c84f	990d5c11fa09e5dda052535555178cc42919a00981494c84149a3cff101fc0ee	3af632e082a9ba9a5e27fe205a425a58a53542cdfca6db5f39e83b4703e26d71	\N
1294	Pride Rides VT	Fundraiser	Help Kris raise funds for us for his birthday!	Kris is running a birthday fundraiser to benefit Pride Rides VT, a nonprofit based in Barre, Vermont. Supporters can contribute to this personal fundraising campaign on behalf of the organization.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0UmgvwACsMvmixbeds9mmWm5ktRiJVMW5bRmrHEnXHPgwc7u4yautJBHjZLdRAzJDl	2026-08-21 10:46:50.274478	active	0c2c25c34c07cee6db4860aec476f5f9b6f37b60327ce7ef7b2fc61db88c6e7e	30aa47b21e0f50ba44b865ccc2ee3851f48e5e83291906d0f2d31a41bf18153d	23fd792754ec40d5d104fd82dd8e172154183f2281db0335f0b6d3250cf65780	\N
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organizations (id, organization_name, mission_statement, town, county, mission_area, website_url, facebook_url, instagram_url, phone, email, donation_url, volunteer_url, primary_source, status, date_added, featured, last_scrape_status, last_scrape_error, last_scrape_at) FROM stdin;
1	Old Spokes Home	A nonprofit bike shop removing barriers to make bikes work for everyone through affordable sales repairs and community programs.	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com	https://www.facebook.com/oldspokeshomeVT/	https://www.instagram.com/oldspokeshome/	\N	\N	https://www.oldspokeshome.com/support	\N	website	active	2026-08-06 20:16:54.295993	t	ok	\N	2026-08-21 10:39:44.563595
6	Local Motion	Vermont statewide walk and bike nonprofit advocating for better infrastructure running community rides and operating the Burlington Bike Ferry.	Burlington	Chittenden	Bikes & Pedestrian	https://www.localmotion.org	https://www.facebook.com/localmotionvt/	https://www.instagram.com/localmotionvermont/	\N	\N		\N	facebook	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:44:42.954511
9	Pride Rides VT	Monthly LGBTQIA+ inclusive group rides across Vermont welcoming cyclists of all levels and identities with loaner bikes available.	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	https://www.facebook.com/PrideRidesVT/	https://www.instagram.com/prideridesvt/	\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:46:50.654953
2	Bellows Falls Community Bike Project	A community bike shop providing affordable bikes repairs and cycling education to residents of Bellows Falls and surrounding area.	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	https://www.facebook.com/bfbike/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:40:25.159745
3	Freeride Montpelier	A collectively organized nonprofit promoting bicycling as an affordable sustainable and joyful means of transportation through pay-what-you-can pricing.	Montpelier	Washington	Bikes & Pedestrian	https://freeridemontpelier.org	https://www.facebook.com/FreerideMontpelier/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:40:58.15661
4	Green Mountain Foster Bikes	Providing Vermont foster children with refurbished bikes helmets pumps locks and oil giving kids in foster care the gift of mobility.	Middlesex	Washington	Bikes & Pedestrian	https://www.greenmountainfosterbikes.org			\N	\N	https://www.greenmountainfosterbikes.org/donate	\N	manual	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:41:08.241222
5	Bennington Bike Hub	A community bike hub offering group rides volunteer opportunities youth programs and bike donations to build Bennington cycling community.	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	https://www.facebook.com/p/The-Bike-Hub-100085570718257/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:41:33.50707
7	Bettys Bikes	A community bike shop focused on education and removing barriers to biking offering affordable sales repairs and an apprenticeship program.	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org	https://www.facebook.com/BettysBikes2015/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-21 10:42:02.195031
8	Vermont Mountain Bike Association	A statewide nonprofit with 29 chapters dedicated to building and maintaining Vermont mountain bike trail network through volunteer stewardship.	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org	https://www.facebook.com/VermontMountainBikeAssociation/	https://www.instagram.com/vmba802/	\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	unchanged	\N	2026-08-21 10:42:23.224931
10	Kelly Brush Foundation	Inspiring and empowering people with spinal cord injuries to be active through adaptive sports programs equipment grants and the annual Kelly Brush Ride.	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org	https://www.facebook.com/kellybrushfoundation/		\N	\N	https://kellybrushfoundation.org/donate	\N	website	active	2026-08-06 20:16:54.295993	f	unchanged	\N	2026-08-21 10:42:29.348612
\.


--
-- Name: content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.content_id_seq', 1294, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_id_seq', 10, true);


--
-- Name: content content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content
    ADD CONSTRAINT content_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: idx_content_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_type ON public.content USING btree (content_type);


--
-- Name: idx_county; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_county ON public.content USING btree (county);


--
-- Name: idx_event_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_date ON public.content USING btree (event_date);


--
-- Name: idx_event_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_event_key ON public.content USING btree (event_key) WHERE (event_key IS NOT NULL);


--
-- Name: idx_mission_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mission_area ON public.content USING btree (mission_area);


--
-- Name: idx_org_county; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_org_county ON public.organizations USING btree (county);


--
-- Name: idx_org_mission_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_org_mission_area ON public.organizations USING btree (mission_area);


--
-- Name: idx_org_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_org_status ON public.organizations USING btree (status);


--
-- Name: idx_org_town; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_org_town ON public.organizations USING btree (town);


--
-- Name: idx_series_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_series_key ON public.content USING btree (series_key) WHERE (series_key IS NOT NULL);


--
-- Name: idx_source_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_source_hash ON public.content USING btree (source_hash) WHERE (source_hash IS NOT NULL);


--
-- Name: idx_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status ON public.content USING btree (status);


--
-- Name: idx_town; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_town ON public.content USING btree (town);


--
-- PostgreSQL database dump complete
--

\unrestrict 9VwaOJx0SYCDeZWd4NCfr56m2Y0ZRbP9fnEJlhQ24SWXGGQaNcC7LIHOyiTCqVB

