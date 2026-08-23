--
-- PostgreSQL database dump
--

\restrict mo4ORIXouFWiVoWZAbAcgXeGNQCbNuPYb0pf2kmAP0yP3VGT0ec1H1eNsDqlNwI

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
1367	Old Spokes Home	Fundraiser	Fall Fundo	Old Spokes Home's annual fundraising ride supports youth bike access programs and Everybody Bikes, which provides discounted bike sales and repairs for income-qualifying customers. The event welcomes riders of all experience levels with four supported routes of 15, 45, 70, and 100 km, followed by live music, local food and drinks, and is open to adaptive equipment users and families with kids.	2026-09-26	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com/support-old-spokes-home	2026-08-23 09:41:58.459792	active	7641bb7ad13dcba5f35622170ba34d5fb428eeab08feef1c97bc521d1fca3e43	a5c68953bacaba60063a48b4e3e5a93e2589ef06ed9c4e1a322f8bd144ae5f87	a9a6962c3eddd1bdacd3a109249bf2978a4e9eb20225c9c1f77fe2c9b52889cd	\N
1368	Old Spokes Home	Volunteer	Drop-In Volunteer Nights	Old Spokes Home welcomes volunteers every Tuesday from 5–7 pm for drop-in volunteer nights where participants help fix bikes, sort parts, support events, and assist with special projects. City Market members who volunteer at these sessions can earn member worker credit through their participation.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com/support-old-spokes-home	2026-08-23 09:42:26.315188	active	7641bb7ad13dcba5f35622170ba34d5fb428eeab08feef1c97bc521d1fca3e43	0876d427aa1c768aec649f009ad9b6bc7c1b2f24d7081c179f2fa33818c54abe	56329821e47340c527a3b605c05c650e28b1f0789569143e280aafbe109e08db	weekly:tuesday
1369	Old Spokes Home	Donate	Bike Donation Program	Old Spokes Home accepts donated bikes in rideable or near-rideable condition during business hours to support their Everybody Bikes program, Kids Bike Bonanzas, and Youth Shop, which gives away over 200 bikes to kids each year. A suggested $5–10 donation to help prepare the bike is encouraged, and donors requesting a tax-deductible receipt should ask at the time of drop-off.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com/support-old-spokes-home	2026-08-23 09:42:26.786871	active	7641bb7ad13dcba5f35622170ba34d5fb428eeab08feef1c97bc521d1fca3e43	692866a7717248accbf8fbffc0d8d5088e78f1b3bc8f7c1438d500407183a025	1aaa8b9714b72d298759be0568a76d8b6ec4601bff3981ed893c7cb5cbe40544	\N
1370	Bellows Falls Community Bike Project	Fundraiser	PEDALS to the PEOPLE Fundraiser Challenge	The Bellows Falls Community Bike Project recently completed their PEDALS to the PEOPLE Fundraiser Challenge, which was described as a great success. The fundraiser provided a significant boost to the organization and drew support from the community.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-23 09:42:31.122163	active	61c616b8ba43273ca3ccdbb93af4721b68678446cf26e4736dad70ddfa2e3e55	088ff83713dc6cb3d94604ab486b025c0a9fb41d39e936475b368abe0e65a1cc	2c217774c9412bcfa5d0a23922048319ac53dd2442c595b6170e5269b13d32bf	\N
1372	Bellows Falls Community Bike Project	Volunteer	Volunteers Needed for Bike Shop Tasks	The Bellows Falls Community Bike Project is seeking volunteers to help with cleaning bikes, parting bikes, fixing flats, and sorting parts at their Bellows Falls shop. Volunteer hours may be applied toward Community Service requirements, and volunteers are encouraged to bring a friend to make it fun while learning new skills.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	2026-08-23 09:42:38.357851	active	61c616b8ba43273ca3ccdbb93af4721b68678446cf26e4736dad70ddfa2e3e55	21b1611d614108399b99a909552630bd521869617d7ca5727c69e37959648ac5	5b6ecc9eb99c43fbc94333c10f83e21bbf100edf1087a871837d663b4cae442e	\N
1373	Bellows Falls Community Bike Project	Volunteer	Vermont Community Foundation Grant for Duet Wheelchair Bike Program	The Vermont Community Foundation approved a $3,000 grant to fund the Bellows Falls Community Bike Project's Duet Wheelchair Bike Program. The program served over two dozen passengers during the Summer and Fall and looks forward to expanding rides in the coming year.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org/our-programs/duet/	2026-08-23 09:42:39.215421	active	7eb62b72041bf9b0e0fdc422dbf56f546dffec29cbd32f56258cbb484809e229	b843a5f4948b961bc260d9541eab255ffdfd1bcd822e534383170bcc70af705c	d369c9e3fc97d42958468a7806e6cc71ceec8d57642ed1eaf9fcf2ad0fa24912	\N
1371	Bellows Falls Community Bike Project	Class	Open Shop	This free after-school program for youth in grades 5–12 runs every Thursday from 3–4:30pm year-round, except on holidays or as otherwise noted. Students learn basic bicycle maintenance and repair and may bring their own bikes, with a maximum of 4 youth indoors or 6 outdoors, and no registration is required.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org/workshops/	2026-08-23 09:42:37.845382	active	964b53311b03f14e377cfffb98231bc2c571957e59fa17b6bbb22f0dc211efb5	2d1ddc77f88d2b2389f039f9892c0b0ed2d8ba9697968d2345cd88a2ae8d9e68	351b571e2f8ddcf775097dc799f1957527d4eeb5002b9956498171b05cc1b659	weekly:thursday
1374	Bellows Falls Community Bike Project	Class	Safe Riding	This free after-school program for youth in grades 5–12 begins in spring with a day and time to be determined, focusing on fun rides around town while teaching students to navigate streets safely. Helmets are required, students may bring their own bikes and helmets or borrow them from the shop, and a maximum of 8 youth participate with two adult leaders present at all times.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org/workshops/	2026-08-23 09:42:52.564714	active	964b53311b03f14e377cfffb98231bc2c571957e59fa17b6bbb22f0dc211efb5	dd38263912a6bf5cb8a2414d3dd9781f2cdf8224a72006985951a47b04e437bc	4ac21e0652a4a3cebced7bdc3167d975ecf1e8d922ff8a2177d3c84d71a153e9	\N
1375	Bellows Falls Community Bike Project	Class	Adult Repair Workshop	This workshop teaches basic bike maintenance and repair to adults, either on their own bike or one available at the shop, starting in spring with a day and time to be determined. A $5–$10 donation is requested, and teens age 16 and older may attend with a parent or guardian.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org/workshops/	2026-08-23 09:42:53.037303	active	964b53311b03f14e377cfffb98231bc2c571957e59fa17b6bbb22f0dc211efb5	e7ba73aafef0e0b102c310f7856aa4775c489d236b8764133af4dae51272078b	f0f25ed1e4e618536223458388c8675b52fa47110ac40a96f3f1a99a8f36e355	\N
1376	Bellows Falls Community Bike Project	Volunteer	Duet Ride Volunteer	The BF Community Bike Project is seeking volunteers to help provide free, secure bike rides using the duet bicycle at events around Bellows Falls. Interested volunteers can stop in during open hours to fill out a volunteer form and schedule an orientation.	\N	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org/volunteer/	2026-08-23 09:42:53.794523	active	d40edf93a5d96b66e424c838dc1ba42eeea8b5220e82ec66350687fa4fc42da5	233f5fdc8d8fac73f44520437444bc003b7d3fe8550983038b4e5772dc14f7e5	1bc139bf71b38d43564b2f48a8df6a9379e202f5058d59e5f786bf0c943f1e07	\N
1377	Green Mountain Foster Bikes	Donate	Green Mountain Foster Bikes Donation Drive	Green Mountain Foster Bikes, a Vermont 501(c)(3) nonprofit, accepts monetary and bicycle donations to provide foster children in Vermont with refurbished coaster-brake bicycles, helmets, pumps, oil, and locks. A donation of $100 covers a complete bicycle setup, and donors receive a receipt and proof of donation for tax purposes.	\N	Middlesex	Washington	Bikes & Pedestrian	https://www.greenmountainfosterbikes.org	2026-08-23 09:43:59.378926	active	f38c02398a4c8e9a171ecd63a94669040d02de9446fd45e590dff21e5895b7b4	a81beb34278604d4354bbdb244c3f6ad5949adc95718e2a78b9e3e106c09354a	922af9d76f3ff0587c26e7b1ee2d5d99bc71b31b270e719404e462251a696a40	\N
1378	Green Mountain Foster Bikes	Volunteer	Foster Bike Rebuilding Volunteer Opportunity	Green Mountain Foster Bikes in Middlesex, Vermont invites volunteers to learn how to rebuild donated bicycles into ready-to-ride coaster-brake bikes for Vermont foster children. Interested individuals are encouraged to contact the organization directly to get involved with this hands-on repair work.	\N	Middlesex	Washington	Bikes & Pedestrian	https://www.greenmountainfosterbikes.org	2026-08-23 09:44:09.292414	active	f38c02398a4c8e9a171ecd63a94669040d02de9446fd45e590dff21e5895b7b4	0acfbeb484589907b7a3fddb2c11201feed4d07603129e430fb7ae69a2ee9546	e068695c143d7c2ffe9d2960aee1824eae915d471f5f01d62c29cd9951a0c841	\N
1380	Bennington Bike Hub	Volunteer	Bike Angel Volunteer Program	Bennington Bike Hub is seeking volunteers to help with bike repair as Bike Angels, as well as people to assist with outreach, website, social media, business planning, and youth educational events. Volunteers can sign up to contribute their skills across a range of roles supporting the Hub's community programs.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-23 09:44:20.214717	active	efe20185594bf063408bb86f1f3d87211e91ce4bb644692fb4ddc4c407aee68d	243031a6aa434980b66a1bd7a5611e43cd6cd00bdda46a3bdc446a2e37458e80	9a83bcea372e94287f61f5bcdc3b99f0dab56ba241cb276cd05d1a1d977d325a	\N
1381	Bennington Bike Hub	Class	Free Mobile Bike Repair Clinics	Bennington Bike Hub offers free mobile bike repair clinics led by trained volunteers in the Bennington, Vermont area. These clinics are part of the Hub's mission to make cycling accessible and safer for all community members.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-23 09:44:20.686221	active	efe20185594bf063408bb86f1f3d87211e91ce4bb644692fb4ddc4c407aee68d	383f2567454081f77344ec92a4ca36a6680a68dfa8f2bdf71b614dee40340ab8	2d6f5e7b7f01257d1e2e4e75aee0428075a706d0658e8a7e88b0acfce5386469	\N
1382	Bennington Bike Hub	News	Green Mountain Power E-Bike Rebate	Green Mountain Power customers can save $200 when purchasing a new e-bike for commuting purposes. This rebate program is available to GMP customers and supports the Bike Hub's goal of encouraging bicycle use for transportation.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	2026-08-23 09:44:21.157239	active	efe20185594bf063408bb86f1f3d87211e91ce4bb644692fb4ddc4c407aee68d	3d7fd7c3f5c165891a11cb7d6764fa26c4022d9de2066307b3eaa7df5c7402bb	16b48a92e55f3d6c157b6ace5b1bf735b8496fbdca397852fa210cb1cf333402	\N
1383	Bennington Bike Hub	Event	August 23rd Community Ride: Family Ride	The Bike Hub is hosting a short, family-friendly community ride starting at the Bennington Firehouse parking lot and ending at Willow Park. Kids, tag-a-longs, and trikes are welcome at this 10am event.	2026-08-23	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org/events	2026-08-23 09:44:21.738869	active	d521797d95b1a5f24cb6903f8f69a51696493056f0da9171352fc1d34916eb4f	07e1ef9a1e6c8e0cd98158ffab2b8f6c6ec85aef7ef055a23cbf8d2c52582e56	414cf22f9b51c1e0a8eab0eb8cac5f78a224b2cadee4d05394949a587279926e	\N
1384	Bennington Bike Hub	Event	Thursday Night Open Shop Night	The Bike Hub hosts an Open Shop Night every Thursday from 6 to 8pm at their Bennington location. This recurring community event provides an opportunity for the public to visit the shop on a weekly basis.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org/events	2026-08-23 09:44:32.066782	active	d521797d95b1a5f24cb6903f8f69a51696493056f0da9171352fc1d34916eb4f	9bbf4ccb8492984af4cd3c0e1fcd884594e2879e90604f1374ae488522489880	d06879f707fe13402b72ee4c620e088c984ae6ef9bbd6a2bb01f5a20c185c1b4	weekly:thursday
1385	Bennington Bike Hub	Volunteer	Thursday Volunteer Nights & Open Stand Time	Bennington Bike Hub hosts after-hours volunteer sessions every Thursday from 6–8pm, open to both experienced and beginner cyclists and mechanics. Participants can connect with other volunteers, work on their own bikes at the open stand, and develop technical repair or retail operations skills, with pizza and refreshments provided — no RSVP required.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org/volunteer	2026-08-23 09:44:39.85878	active	3b113e255bff5a04d9ff25764c4c9aa688aed92a9333c64f1e32694c5559473e	8a040eec2bf8d54a989793d05a7c6c69fa5aad97c60e49497a8e7c0167f19488	9073d7db207e596f6afa36aa59f17843611c99c54a61523359a76075f537809d	weekly:thursday
1386	Bennington Bike Hub	Class	Earn-a-Bike Program	Bennington Bike Hub's Earn-a-Bike program is designed for young community members who want to get involved with cycling through a structured engagement opportunity. The program is referenced as part of the Hub's broader goal to engage and empower youth in cycling.	\N	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org/volunteer	2026-08-23 09:44:40.330438	active	3b113e255bff5a04d9ff25764c4c9aa688aed92a9333c64f1e32694c5559473e	41886ad45ae1234837e9e81de6210d8305d8c3184c6d7312e141973068ec51e1	2a5d6de97e81aa0c3a05445946095e813232e4ecde2dbfbc36c7231b322298a7	\N
1379	Bennington Bike Hub	Event	Our Gravel Ride '26	Bennington Bike Hub is hosting Our Gravel Ride '26 on September 12th in the Bennington, Vermont area. This named gravel riding event is organized by the hub located at 160 Benmont Avenue, Suite 36, Bennington, VT.	2026-09-12	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org/rides-and-routes	2026-08-23 09:44:11.96825	active	4a8fa5497bc3eb2ac9191ece23acc974b7cb25032d8e2fa4f70cb350a3898e7d	a73d56c5cafa49c6b2f9ba41682d2ae6aba8bea6abd3ccbafb72cdda398a0c2f	7949960d0b0832105d1924db66ebf08e2949963e46e3a5f4aec2512d2a4e572f	\N
1387	Bettys Bikes	Class	Apprenticeship Program	Betty's Bikes in Burlington offers an apprenticeship program focused on assisted bike building and repair, with applications for the current season now available. Interested individuals can request an application by emailing Bettysbikes@gmail.com or asking directly at the shop.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org	2026-08-23 09:45:03.535663	active	a6079131d60f7a65ef027f2efdfd87779714b50a677d93e95bec6135beead218	cbee444a44ffdb512d65fd6a8d77f88e95e1d7231ec9bada10dc40eb890bc1d1	b33b1a96686f89c2cd4b92a6e0c79334e0e96815bc3505f31572efdd4b9acc3f	\N
1388	Bettys Bikes	Class	Bicycle Mechanic Apprenticeship	This two-to-four month comprehensive bicycle mechanic course meets one to two days per week on Monday, Wednesday, or Saturday afternoons from 1–6:30, with a maximum class size of three students per session. Students receive hands-on instruction, supervised work, and an immersion session, and graduate with a certificate of completion, a detailed skills record, and letters of recommendation for related jobs.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org/bettys-bikes-apprenticeship-program/	2026-08-23 09:45:27.068128	active	3f4eb96f143985ddd7bae09b4d256fec71833c8bba7f03d5f80041a0a3eb60d0	e9b90ab48c54f82e45890887f518b26b15bce72880c052c1df451dc4f3751cc7	b98a79e7a24c40009ff72d9b991be245aee9ee215449472267d5a8352f43bd4c	\N
1389	Bettys Bikes	Event	Frame Fest	Frame Fest - see event page for details.	2026-09-06	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org/event/2644/	2026-08-23 09:45:37.862052	active	0cee47ade37c962a83e31f0058aafbce0956d2ed63ff915b43c51fe03dee8d62	a838dc0e777f95ac0884d5ba89b5a92540c17cb9886304b295faec06dce28b24	d53a997571d4e4037932b3dfdcffb835626a23689cf8c0cd234cfc8055a2e360	\N
1395	Vermont Mountain Bike Association	Volunteer	Reward Volunteers Program	VMBA's Reward Volunteers program allows volunteers to log hours worked with any VMBA Chapter or Community Builder bike programs (including Vermont Adaptive, Unlikely Riders, Little Bellas, Pride Ride VT, and VT Youth Cycling), with each hour counting as one raffle entry to win monthly prize packs. Monthly prize packs include items such as a Cabot gift card, VMBA membership and swag, Cane Creek components, Five Ten shoes, Velocio gift card, and more, with a grand prize including a Thule bike rack, Crankbrothers Synthesis Enduro Alloy wheels, and a Trek Brevard RSL XT TLR.	\N	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/rewardvolunteers/	2026-08-23 09:45:59.610923	active	c513a5c3a4c9c0c9b8caf1ab514007cb8dee3071be4d21dc1e5cce13d2de94f5	b1af4055e589ff940609e7c81f7584e1dcfb018e93e9b9ddd6ac6a25437fc097	05fd91f0ea63b4edec58a1bd6a33b3849a8d9dd1a6212032482c6309bc0c6d8f	\N
1391	Vermont Mountain Bike Association	Event	Bike-in Movie Night	Ride your bike to Old Spokes Home for a good old fashioned movie night! The parking lot is our venue. We’ll have a large screen and projector in front of the shop, and you can set up chairs or a blanket anywhere you’d like. Please BYOSeating although we will have some chairs on hand. (We’ll	2026-08-23	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/bike-in-movie-night-2/	2026-08-23 09:45:44.64306	active	c5e1cbef12d3163d98b48f47ca1fcde228390f260a5b24a7503a6f3cdd6a0957	effe02651ad91943dad247905854a1b6b2f6dbd00eba28dde8199f60b2bdd73f	38acdf4cee49b31f241e5c6812c36c03183ede41af6ccab2c5f1a5ba09c4b260	\N
1390	Vermont Mountain Bike Association	Event	WAMBA – Triple Crown Throwdown	The 2nd Annual Triple Crown Throwdown returns bigger and better than ever! Come experience the best of riding in the Woodstock Area with a race across all three WAMBA networks. More info will be posted this spring. Registration and details will be posted here: https://www.bikereg.com/73579#Notes	2026-08-23	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/wamba-triple-crown-throwdown/	2026-08-23 09:45:44.17127	active	c5e1cbef12d3163d98b48f47ca1fcde228390f260a5b24a7503a6f3cdd6a0957	a5595d6d811d65350ebaaabaed1498f3ffbf49cf298df6b85a7d80269c566d6b	3f8dcb4dc89a1ad4e3accb9acaac7edaeed77632d228e9c585ba3541ca4ee6ee	\N
1393	Vermont Mountain Bike Association	Event	2026 Delta Dental Race To The Top Of Vermont	RACE TO THE TOP OF VERMONT Join us for the 2026 Delta Dental Race To The Top Of Vermont on August 30th in Stowe! This year marks the 20th Anniversary of Race To The Top, our annual fundraiser for the Catamount Trail Association.  Bring your friends and family and join us for a run, bike,	2026-08-30	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/2026-delta-dental-race-to-the-top-of-vermont/	2026-08-23 09:45:46.424193	active	c5e1cbef12d3163d98b48f47ca1fcde228390f260a5b24a7503a6f3cdd6a0957	321aeba020eff99e50439285a08acd68dc3f09c2cb7ba2a1b165a8bf65e51292	a40da775738133629b518070fad4445f8b244fd4a12a5cccabcba3e03616391a	\N
1392	Vermont Mountain Bike Association	Event	Stowe Trails Partnership S&A Trail Work Night	Join Stowe Trails Partnership every Monday evening to help build Stowe’s first directional double black trail- Serenity and Adrenaline! Meet here at 5:30 on Mondays to head up to trail that is filled with rock rolls, drops, and other natural features galore. What to bring: Closed toed shoes Water Your favorite tool (if you have	2026-08-31	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/stowe-trails-partnership-sa-trail-work-night-14/	2026-08-23 09:45:45.382535	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	0dcf95a2a49a1ba975339fdba23ee547b8354455f5c03a7342096f191981d6eb	8f162b391e0b6bf1665de774f5a5d8fc2a013c64720479a2966c750057d8299e	\N
1394	Vermont Mountain Bike Association	Event	VMBA Days – Bolton Valley	The VMBA Days series is coming back for its sixth season with some new great additions. We’re beyond excited to welcome back Lawsons Finest Liquids as the presenting partner of the series. We’re also happy to welcome POC as a supporter of the series as well. For DH, we are bringing back our ‘New to	2026-09-05	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/vmba-days-bolton-valley-2/	2026-08-23 09:45:59.139933	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	fb26bc60f90239cd31e148fbf3fd0de008b8c3a2a6def1b19e1321d87fe7b09f	e48bdee6a5ff09253fa5884ea94d11958d00749d7286b27094745bf8cd2e4e06	\N
1396	Vermont Mountain Bike Association	Event	VTYC – Race #2 & 3: Burke Mountain XC & Enduro	VTYC – Race #2 & 3: Burke Mountain XC & Enduro - see event page for details.	2026-09-12	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/vtyc-race-2-burke-mountain-xc-enduro/	2026-08-23 09:46:48.971442	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	e4c936c51f2b491f0dfeaaf6ec578239c161f3d3d3ba985ad14f366fc2901165	3242001240558ac93f1e684309798d3b9a75d4117052022f85ec5e892bfbc396	\N
1397	Vermont Mountain Bike Association	Event	Pedal for Prevention Gravel Ride	Greetings Pedal for Prevention Riders! September is National Suicide Prevention Month. We are excited to support the American Foundation for Suicide Prevention. Please consider a donation in addition to your registration. Every dollar, every rider, every shared moment contributes to breaking the stigma and providing support. All donations are 100% tax-deductible and directly support AFSP’s research, education,	2026-09-12	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/pedal-for-prevention-gravel-ride/	2026-08-23 09:46:49.443768	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	932ca85ec2a763ed3a19ff8a3f19f3355b37f28efa4bfe01545e876da29e68a1	5503173f07056e069d88f34f8eac6f94cc50f9a34f7fc2eb44f6c56156182658	\N
1398	Vermont Mountain Bike Association	Event	VMBA Season S’ender	Eventbrite Tickets Send off the season with the VMBA community. We’re headed to Slate Valley for the 2026 Season S’ender – join us for a full weekend of fun! VMBA, Lawsons, and SVT are working together this year to host our fourth end-of-season party, now named the Season S’Ender! As with previous years, this event	2026-09-19	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/vmba-season-sender/	2026-08-23 09:46:49.915611	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	f1793be353614d99f39806188496cf6babd326b2b4395972decc9232f037bf0f	d6948ae0fd064ff26ea64be39927415297a38558f81801e1e8130c6e922d0213	\N
1399	Vermont Mountain Bike Association	Event	VTYC – Race #4: Woodstock Mt Peg Enduro	VTYC – Race #4: Woodstock Mt Peg Enduro - see event page for details.	2026-09-19	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/vtyc-race-4-woodstock-mt-peg-enduro-2/	2026-08-23 09:46:50.387162	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	127df454a621c8eac6243fac6e8c9264c15cceef7c1ce453b9f8fae85e256553	5797c2ef2c73bde9b5d484a8da062b3a9373d22285a1bf1e574162536b7ae7e5	\N
1400	Vermont Mountain Bike Association	Event	Old Spokes Home Fall Fundo	It’s a ride, not a race! The Fall Fundo supports the work of Old Spokes Home, a nonprofit bike shop. Choose between four different ride lengths from 15k to 100km. Enjoy an after party at the shop with live music, local food & drinks, and fabulous raffle prizes. Pedal together and fundraise your hearts out	2026-09-26	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/old-spokes-home-fall-fundo-4/	2026-08-23 09:46:50.86157	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	4c3a3201dbc5fc1fa3738d3f2671d6ea1ff395e017c97936193ef7d2f85b6ace	0476b8012c1ac7f3c89273d83da68b02f325bbd5c3ae041e9b48ea27c27ad83f	\N
1401	Vermont Mountain Bike Association	Event	MRR – Valley Dirt Fest	MRR – Valley Dirt Fest - see event page for details.	2026-10-03	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org/event/mrr-valley-dirt-fest-2/	2026-08-23 09:46:51.604675	active	b3e2c4a3c4b3944032b0e2ba795e54ab98fab24d80d7fa7eb9d67e528656ea50	9c41a478da2c14c089a773bab1ba43785060d80a72f33d01678135c7dede88bb	7091bc7c21ac481addf66973fc34fcf596d69409fe3be317d4cb70792990de5f	\N
1403	Kelly Brush Foundation	Event	21st Annual Kelly Brush Ride: Vermont	The 21st Annual Kelly Brush Ride powered by Union Mutual takes place in Middlebury, Vermont, or remotely, offering participants an exhilarating day of cycling in Vermont. The event is open to both in-person and remote participants.	2026-09-12	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:54.612675	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	7918c163543754f0f8ae7cb97d12e4a2f567bca8a6690d843fe32e9c025f7ba3	5f44f01ee0238d9dfad73d6c2063f55e60456caee3eefce3d0cca3118bba6073	\N
1405	Kelly Brush Foundation	Event	Best Day Ever: Burke	This screening of the documentary film Best Day Ever takes place in Burke, Vermont, at a location to be determined. The film follows KBF's Chief Program Ambassador Greg Durso and community member Allie.	2026-09-29	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:55.554668	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	f576faf38f8b7e4e51160dca9da5b063f9776a0bf2f75737123d8d4ae153c73f	8a894b133129097370acf060a8456622e5794cfc1b3e141e899d344529004afe	\N
1407	Kelly Brush Foundation	Event	aMTB Camp Downhill Day	The aMTB Camp Downhill Day takes place at Burke Mountain in East Burke, Vermont, and is limited to pre-registered and invited attendees due to resource limitations. Interested participants can submit their information for consideration.	2026-10-01	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:56.498253	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	657dc4a65bd02e4325439505ef56527319f22abc4a3d9239db2d25e8b37c2c8b	bb57598100c4d2ed3d9a542bcc690049c32a500f65443997f1332f8f9217eaa5	\N
1402	Kelly Brush Foundation	Event	Adaptive Rec Talks – Tennis	This Zoom-based discussion group session focuses on the topic of Tennis and is part of the ongoing Adaptive Rec Talks series hosted by Kelly Brush Foundation. The session takes place at 5:30 pm as part of a recurring every-other-Tuesday format.	2026-09-01	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:54.140903	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	ddccabc706f49b67d944f8120d4eee8aa09fabccaee1107e79dd89e5c578035d	bc9a644702cbbe867e4c9d9ea89b0c2df4bb9aca4cea842d60b91f4395c644f9	\N
1404	Kelly Brush Foundation	Event	Adaptive Rec Talks – Pickleball	This session of Adaptive Rec Talks focuses on Pickleball and takes place on Zoom at 5:30 pm, hosted by Kelly Brush Foundation. The series is a vibrant and inclusive discussion group meeting every other Tuesday.	2026-09-15	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:55.083676	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	8f733b6788c55dc7a74f3359ea77a46ddc607cdedeff6a9c3273b899d1f9e7e4	68feb286f28ed2fe79c318a4985e7435f947fe5e58985b56c121f4b2cdaf51b1	\N
1406	Kelly Brush Foundation	Event	Adaptive Rec Talks – Archery	Kelly Brush Foundation's Adaptive Rec Talks series hosts a discussion on Archery via Zoom at 5:30 pm. The series meets every other Tuesday as an inclusive discussion group for adaptive recreation topics.	2026-09-29	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:56.02621	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	8ab7a87795bbdc4ec9aa35fa76318e12ed2fc5a7305017727f9262a7d801e795	dbc7a6fb9ba49bf63c95814b976270e7b1f32957f3f101bc31f59b3dbf97e7ab	\N
1420	Local Motion	Event	Little Lake Lessons	Lake Champlain Sea Grant staff and local partners gather at the end of the Causeway one day per week during summer to share knowledge about the lake with visitors waiting for the Bike Ferry. Topics covered include the lake's natural and cultural history, geology, ecology, its challenges, and recreational and stewardship opportunities.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0G8zx1AcCSuKxqrR4Q6NhcEQXQoznc8yC3npiBS6CQLSYKBRN19evFjz9z7G1UXSLl	2026-08-23 09:49:49.562127	active	02fb6f13d1ced38b44e4fd3cb4ec88c93649dee7ba3d49024bacd15fbdf5e4fb	2afa01a93a50663aaa6952c77fd7d7eeb9aa0a0882af8108f228d132b054e829	5d88731a6a1d184000b797f91ea38e13f26b716a64a9d6053f3b2b832a4be566	\N
1421	Local Motion	News	Waterfront Concerts Valet Bike Parking Unavailability	Local Motion has announced that Valet Bike Parking will not be available this year for the Waterfront Concerts in Burlington. The concerts run from July 30 through August 2 in Burlington, Vermont.	2026-07-30	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02HCGLrQUVzVgciXHapJMCcRuyTWjLKpj4DdsgvWtd1Ph1k8T5gJ2Uv1tzaWgoBPDRl	2026-08-23 09:49:53.991332	active	85c38cfe26868ff098ced1711af89ccbf3dbd7efea14ab3303cd4f827521a6aa	4efa5541cd1e286493cbf9470b34d27c531890bfe682437755d6883f663b6ae2	b8f16173d9e2e128d1cf7bed6fe4dc8c5be557293a0cc9bf12fc8bb233808927	\N
1422	Local Motion	Fundraiser	Local Motion Summer Appeal Raffle	Local Motion is running a Summer Appeal fundraiser where donors can enter a raffle to win a bicycle trip for two to Spain with VBT / Country Walkers, along with other prizes. Each raffle entry costs $10, and donors receive a bonus entry for every $60 donated through August 31.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0i35M6fERF2fmaGxrmrKbJkhHKhJQsEGyfiKsKxYejyQs2upUaVadYDzyhgZYTKgAl	2026-08-23 09:49:57.134982	active	2018290d9ef316355434ff3add815d65e927df8abd3cac726e9b460644d20727	343a2c87d95d82def417a730aa31bc0a6284d9e19dd8569f1fde78c4b6dbd95c	8c446cbda22ebfb3f537f1f463f76f5c90bcb0405e76535d52fbc04b66166951	\N
1423	Local Motion	Class	Bike Smart	Bike Smart is a program run by Local Motion that teaches safe biking skills to thousands of Vermont children each year. The program is supported by M&T Bank as a sponsor.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0iipzSRxPAxtA7SyRvn7tRZrpwQGmHox1sFRajGr3Hoa8cp6YqbLWsWFwkjKoaWuUl	2026-08-23 09:50:05.496837	active	6cc9bd8fa8631dda7541bd414003649820434d4e0b32f5a13860b4e494a314cf	daad95fdc4f2e37ad664080b75463f902f6b3d2a22f1caf676430558993ef225	b5c1248aa5db9fa267bddcad2749ba1f49e5dc1d53efb73158189a32c9a4d628	\N
1410	Kelly Brush Foundation	Event	Killington World Cup Weekend	Killington World Cup Weekend November 27-29, 2026 Killington Ski Resort, Killington, Vermont More information coming soon! Stay tuned.	2026-11-27	Burlington	Chittenden	Bikes & Pedestrian	https://kbf.org/event/killington-world-cup-weekend/	2026-08-23 09:46:57.916042	active	9d5ce4e159f5235606c1fa3c62865519ecd8feaa06ca1ca9a39c497f836b0918	f23ae2a2d5918cfdf374b1565c6aef1ac6826a8fa117bc4d270ca35753d7f9a8	7173807e48c06199345e2fb7f54de49429a12629b2411c8e8d5fedde73f6839d	\N
1408	Kelly Brush Foundation	Event	Adaptive Rec Talks – Fencing	The Adaptive Rec Talks series turns its focus to Fencing in this Zoom-based discussion session at 5:30 pm, hosted by Kelly Brush Foundation. The group meets every other Tuesday for inclusive conversation about adaptive recreation.	2026-10-13	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:56.970934	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	18f7ed3aff1676cb82c7eb637119a7c3a79eb7af839b3a4bfb149445c2e4507f	906b287015338b7cb2dcf9d47a19712b73455be250e7b4f298c5d8f062525338	\N
1409	Kelly Brush Foundation	Event	Adaptive Rec Talks – Rowing	Kelly Brush Foundation's Adaptive Rec Talks series hosts a Zoom discussion focused on Rowing at 5:30 pm on October 27. The series is a vibrant and inclusive discussion group that meets every other Tuesday at 5:30 pm.	2026-10-27	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org/calendar	2026-08-23 09:46:57.443341	active	7f61aba0f63249af4b69e7f5be18565d276788b01fd7020ebd12a1d8adb002f2	6ecc5c16f054e05792deb0578e5a45d2d11583660fc31c750a08068a63f8db3b	47a9196ab1ca25715dceaa12d55988042388336d3e044af499ed60b9239c9115	\N
1411	Pride Rides VT	Donate	Pride Rides VMBA Community Builders	Vermont Mountain Bike Association members can select Pride Rides as a Community Builder add-on when purchasing their annual VMBA membership, directing support to the Barre-based LGBTQIA++ cycling nonprofit. Choosing this option demonstrates to VMBA and the broader community that Pride Rides deserves representation, beyond simply donating $30 directly to the organization.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/support-and-donate/	2026-08-23 09:47:34.08106	active	172958fc7d4376c272ac75ce101de9dbd8dcaeedc1703066b1968d977feda208	816b0afe38297c0477c7ccc881925b74758c9f709b7ec2730254a1a93b2a64b0	f26572e4327a8e3fe73690bf4a85ea7a3b7424e26783cb9543a2a4731a11c9b7	\N
1412	Pride Rides VT	News	WCAX Interviews Pride Rides Vermont	WCAX, a Vermont television outlet, conducted an interview feature on Pride Rides Vermont. This media coverage highlights the organization's work and visibility in the Vermont community.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/prides-rides-in-the-news/	2026-08-23 09:48:07.982286	active	393f2cbd9dc168a1bd91664942a8f1de6fc948e57dccd605e6415ae90cd43323	58c53c77289efb3572f7a066dd663ebd194fc6aa6e2d94531fe6fef4f8ef1659	64b28534a2720e6f2cce06c23f8d844ec1ddd87bba408862e2ab3ea98a6e371b	\N
1413	Pride Rides VT	News	Vermont Huts Guest Column by Kris on Pride Rides	Vermont Huts invited Kris from Pride Rides VT to write a guest column about the organization and its rides. This piece provides an inside perspective on Pride Rides VT directly from one of its members.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/prides-rides-in-the-news/	2026-08-23 09:48:17.613362	active	393f2cbd9dc168a1bd91664942a8f1de6fc948e57dccd605e6415ae90cd43323	abbcd571d9960edeb594a159cdda70b1b3369c7940fde08f7653e764afa3d93f	144ff3658a9dc13c8d3a01584ab8940f624eaefd7ee9f970873c6f8552ad28c2	\N
1414	Pride Rides VT	News	Bike Borderlands Spotlight on Pride Rides VT	Bike Borderlands published a spotlight feature on Pride Rides VT, drawing attention to the organization's mission and activities. This coverage helps amplify Pride Rides VT's presence beyond Vermont's local media.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/prides-rides-in-the-news/	2026-08-23 09:48:18.085087	active	393f2cbd9dc168a1bd91664942a8f1de6fc948e57dccd605e6415ae90cd43323	d25a59e010312bb4321b3f6ec174acf49a8fb8d9ae133fcd84ffd8de609fcf18	ff91a73085f0c48d71453109fba66138933e2919ac579ddfd09c95b220018944	\N
1415	Pride Rides VT	News	VTDigger Write-Up About Pride Rides	VTDigger, a prominent Vermont news outlet, published a write-up covering Pride Rides VT and its work in the state. This article contributes to broader public awareness of the organization among Vermont readers.	\N	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/prides-rides-in-the-news/	2026-08-23 09:48:18.557711	active	393f2cbd9dc168a1bd91664942a8f1de6fc948e57dccd605e6415ae90cd43323	93bde62a68b40ad7b03b043a1b8eb7174ffb650270624e12906a2a6c16e60692	42f71848308832ecff8196d3d36d8950bc5879dd0116fee124f63549b81ff55d	\N
1416	Local Motion	Event	Bike-In Movie Night at Old Spokes Home showing Best Day Ever	Old Spokes Home in Burlington is hosting a Bike-In Movie Night screening of the film Best Day Ever. This event is part of a broader series of biking, walking, and rolling community events happening across Vermont in August.	2026-08-23	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0222tMMrGc3L8nZCuJuomgLqNFyTBe2nSAUJojU2zLu8A3oHyVZce2GPccRVTEk1dl	2026-08-23 09:49:15.119357	active	d68621346aeb52444b7c36cd1395ec89a41a22530edea3d77f6241d221e8d620	55621e6200f8c717c044857450a3c566321e252680867792028f0671f7cc3f73	a6e19af3d620b6d19ff967aecf1dcd03e7ac6e89823b7a1f8531ddb0902df288	\N
1417	Local Motion	Employment	Bike Rental Shop Part-Time Staff	Local Motion is hiring part-time employees to work at their bike rental shop on the Burlington waterfront, with responsibilities including greeting customers, processing reservations, and fitting customers to bikes. Shifts are 5–6 hours long (mornings or afternoons), seven days a week through the end of October, with pay starting at $15–$18 per hour depending on experience.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid0fzh4hjTd3yP2V8ivragsVgDf5kxBzSTSw7ieLcs5sxe9We9wPy3TZbJa1X54QtoAl	2026-08-23 09:49:30.830989	active	e895a64326c9cc42d05d62819b9e59b60afc96ac3631f22c3417038594d32dce	c05c8edcd2bf443fa23b7a34aef1b174e55fd7eb40fea95242093dc0f3dd872c	bd3bf53b5eb882ee3e3fd923af8c3b2d308fb1c03064648e8e593e0e7fd69117	\N
1418	Local Motion	News	Bike Ferry Closure for Maintenance	The Bike Ferry will be closed on Tuesday, August 11th while maintenance is performed on the boat. The Island Line Trail will remain open during this time.	2026-08-11	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02PkD14iqXdQcvxqHAc37dFZehswQUj6TGW3uLHufiDKkYvzTeJ6ovN9y8hE5Z6GG8l	2026-08-23 09:49:33.330299	active	fd3c713e23e5104bd3b5ceb57941a56641d27ac6ceed51358084b54ffbfbb20b	ea7b67cf9dddbb3ab1ba71df79164c0577316f0f5cd6dd37212893dde36d66ab	264a7ee532a501df8f671e06c781f6dbab7bca075c259f3ab44080764cdedd26	\N
1419	Local Motion	News	Burlington Bicycle Friendly Community Survey	The City of Burlington has applied for Bicycle Friendly Community status from the League of American Bicyclists and is seeking public input on local bicyclists' experiences. Anyone who lives, works, commutes, or recreates in Burlington is encouraged to complete the brief survey.	\N	Burlington	Chittenden	Bikes & Pedestrian	https://www.facebook.com/localmotionvt/posts/pfbid02gET7U3f4bVsGBpsCuidHedQa82rqYANwtucZ1Na3VUqTqYbgyZbtpQAFGZZcbEV8l	2026-08-23 09:49:42.656405	active	02c34a2ec2d3cb4fa725994cd20f0db167ed7ac4697737f14b8271f8be1f5e75	88e78d89809e5c036d8ab95bbc2c0ffe68da93244b688518170e41511db964aa	cf660d971eca26d529f04fce356663d43847bbfa75c6a58da9aa3c6a376f2b0c	\N
1424	Pride Rides VT	Event	Annual Bikepacking Adventure with Vermont Bicycle Shop	Pride Rides VT and Vermont Bicycle Shop are hosting a multi-day bikepacking trip departing from the shop in downtown Barre, traveling up and over to Plainfield and down the rail trail to Ricker Pond campground in Groton State Forest. Participants will camp overnight in a pre-reserved lean-to or cabin and enjoy a full day of bike adventures, campfires, swimming, and relaxation before returning to Barre via the same route in reverse.	2026-09-05	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0jMQvF69nLJTPWJykv9d5rCExecms6v3hmPGnDAx7SojG8R7LGuUMJvWrDfqs5vKsl	2026-08-23 09:50:48.270411	active	38771ae0792012bb0c6f09d0398e29e8dca852b7b17151a5e4d6d6d1543811b6	e4121441d28fd4a915271d58dba69501545e73f742398d1beb70086dd02f38d9	e1685d9822d3ef58e0265aaf0db29e27df55a9cad23b7c8e911b04955f28e433	\N
1425	Pride Rides VT	Event	Bikepacking Adventure Informational Meeting	Pride Rides VT is hosting an in-person informational meeting at Vermont Bicycle Shop on August 25th at 5:30pm for those interested in the upcoming bikepacking adventure. Attendees can ask questions and learn details about the trip from Barre to Groton State Forest.	2026-08-25	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0jMQvF69nLJTPWJykv9d5rCExecms6v3hmPGnDAx7SojG8R7LGuUMJvWrDfqs5vKsl	2026-08-23 09:50:56.532214	active	38771ae0792012bb0c6f09d0398e29e8dca852b7b17151a5e4d6d6d1543811b6	3569926657ffa04e6fa5e4de21638af3083067ed25a70dd2289f5668cb4db7a0	faf7ab6383b9193d4ced13bc87986c062a11235e879baf3528a659deaafa58eb	\N
1427	Pride Rides VT	Event	Mountain Bike Group Ride at Queer Arts Fest	Ride leader Harlow will lead an all-levels mountain bike group ride at the Queer Arts Festival on Little John Rd in Websterville, VT, beginning at 2pm and lasting approximately 1.5 hours on the trail. Participants can borrow bikes and helmets by reserving in advance, and helmets are required for the ride.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0pbnKZAEmYEeTpdxezzmkbunRGurjoGorFJYAnmFKimWmTZNybGSjswWdNGodeBJkl	2026-08-23 09:51:19.898477	active	34400555fbbdbe740a8b78009f37737156ae7aa183a0b41163d81d44f27723c1	8974eac61b4921eeeb2f465dce921e79d19f7caa23ceb3e8236764a122d232c4	4ae15773279072124c65f19d22cff4ef79ec35c23bc34da51b686bc4e712ac75	\N
1426	Pride Rides VT	Event	Family Friendly Gravel Group Ride at Queer Arts Fest	Ride leader Harlow will host a family-friendly, all-levels gravel group ride of approximately 3 miles at the Queer Arts Festival on Little John Rd in Websterville, VT, starting at 9:30am. Bikes and helmets are available to borrow in advance, and helmets are required for all riders.	\N	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0pbnKZAEmYEeTpdxezzmkbunRGurjoGorFJYAnmFKimWmTZNybGSjswWdNGodeBJkl	2026-08-23 09:51:19.425563	active	34400555fbbdbe740a8b78009f37737156ae7aa183a0b41163d81d44f27723c1	06f30129f0aff3b17186cd1621abcfc88374e49fab4ebf326c2e33667b18030e	0f8863e7339473caad3d2d7644ead69dc93cfe99716ebb55872a881c8318399a	\N
1428	Pride Rides VT	Event	Barre Pride Ride	Pride Rides VT is hosting a bike ride around Barre that leads to the Barre Pride festivities. Pizza will be available at the event.	2026-08-29	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0dzVVQ6RRGUAGXCV2jZPdG4VNyrWP7SfgmpbhkdjrXSwh9wV2KmC6kjQFbmdteV21l	2026-08-23 09:51:53.058841	active	d4344fd98e7f8973981bf0ebaee7f097636c835916fb031fab82abdc5258e593	28c0459905208b3daad13622349e39ea069b873933c4385f1cd1b6be3c5ab12c	eb398fc3392fbf5956038f6ee058f08caa9f148c9b151f9552d6669372e1a047	\N
1429	Pride Rides VT	Event	Essex Pride Tabling	A few Pride Rides VT members will be tabling at Essex Pride in Essex, Vermont. The event is scheduled to take place rain or shine.	2026-08-24	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid0dzVVQ6RRGUAGXCV2jZPdG4VNyrWP7SfgmpbhkdjrXSwh9wV2KmC6kjQFbmdteV21l	2026-08-23 09:51:53.530776	active	d4344fd98e7f8973981bf0ebaee7f097636c835916fb031fab82abdc5258e593	8f55b584b1d9828416b5bcc98a0d3a729031a6156d86959853c85fcb22112ed8	e2f72dc49e511cb3b1887e110027098adaabc1563b7307e25241d5800ae940a7	\N
1430	Pride Rides VT	News	Pride Rides VT Pamphlet Distribution Tour	Pride Rides VT is touring around Vermont starting Saturday, visiting bike shops, trail centers, queer spots, and other community locations to share information about the organization and its rides. New pamphlets designed by Caroline P and printed by CW Print Design will be distributed at stops throughout the state.	2026-08-29	Barre	Washington	Bikes & Pedestrian	https://www.facebook.com/PrideRidesVT/posts/pfbid02sAxkznJkGAHL6TUJb12ajSRouwasMzRxGfu2hui8Jh5b1SiYTdW2U5iDN3gstcUSl	2026-08-23 09:52:03.901758	active	86087830af48dc14a3fb21c226cbfaf0bcb0d1c8b4597835567a4b4163611357	4004e0b5d786a7adda65b44013aa6b34432394e2bcb8c8a6cd5998314c6f71bc	3af632e082a9ba9a5e27fe205a425a58a53542cdfca6db5f39e83b4703e26d71	\N
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organizations (id, organization_name, mission_statement, town, county, mission_area, website_url, facebook_url, instagram_url, phone, email, donation_url, volunteer_url, primary_source, status, date_added, featured, last_scrape_status, last_scrape_error, last_scrape_at) FROM stdin;
6	Local Motion	Vermont statewide walk and bike nonprofit advocating for better infrastructure running community rides and operating the Burlington Bike Ferry.	Burlington	Chittenden	Bikes & Pedestrian	https://www.localmotion.org	https://www.facebook.com/localmotionvt/	https://www.instagram.com/localmotionvermont/	\N	\N		\N	facebook	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:50:05.96905
9	Pride Rides VT	Monthly LGBTQIA+ inclusive group rides across Vermont welcoming cyclists of all levels and identities with loaner bikes available.	Barre	Washington	Bikes & Pedestrian	https://prideridesvt.com/	https://www.facebook.com/PrideRidesVT/	https://www.instagram.com/prideridesvt/	\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:52:11.043724
1	Old Spokes Home	A nonprofit bike shop removing barriers to make bikes work for everyone through affordable sales repairs and community programs.	Burlington	Chittenden	Bikes & Pedestrian	https://www.oldspokeshome.com	https://www.facebook.com/oldspokeshomeVT/	https://www.instagram.com/oldspokeshome/	\N	\N	https://www.oldspokeshome.com/support	\N	website	active	2026-08-06 20:16:54.295993	t	ok	\N	2026-08-23 09:42:27.258483
2	Bellows Falls Community Bike Project	A community bike shop providing affordable bikes repairs and cycling education to residents of Bellows Falls and surrounding area.	Bellows Falls	Windham	Bikes & Pedestrian	https://bfbike.org	https://www.facebook.com/bfbike/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:42:58.938624
3	Freeride Montpelier	A collectively organized nonprofit promoting bicycling as an affordable sustainable and joyful means of transportation through pay-what-you-can pricing.	Montpelier	Washington	Bikes & Pedestrian	https://freeridemontpelier.org	https://www.facebook.com/FreerideMontpelier/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:43:22.227993
4	Green Mountain Foster Bikes	Providing Vermont foster children with refurbished bikes helmets pumps locks and oil giving kids in foster care the gift of mobility.	Middlesex	Washington	Bikes & Pedestrian	https://www.greenmountainfosterbikes.org			\N	\N	https://www.greenmountainfosterbikes.org/donate	\N	manual	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:44:09.762893
5	Bennington Bike Hub	A community bike hub offering group rides volunteer opportunities youth programs and bike donations to build Bennington cycling community.	Bennington	Bennington	Bikes & Pedestrian	https://ourbikehub.org	https://www.facebook.com/p/The-Bike-Hub-100085570718257/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:44:49.000141
7	Bettys Bikes	A community bike shop focused on education and removing barriers to biking offering affordable sales repairs and an apprenticeship program.	Burlington	Chittenden	Bikes & Pedestrian	https://www.bettysbikes.org	https://www.facebook.com/BettysBikes2015/		\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:45:38.332986
8	Vermont Mountain Bike Association	A statewide nonprofit with 29 chapters dedicated to building and maintaining Vermont mountain bike trail network through volunteer stewardship.	Waterbury	Washington	Bikes & Pedestrian	https://vmba.org	https://www.facebook.com/VermontMountainBikeAssociation/	https://www.instagram.com/vmba802/	\N	\N		\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:46:52.076501
10	Kelly Brush Foundation	Inspiring and empowering people with spinal cord injuries to be active through adaptive sports programs equipment grants and the annual Kelly Brush Ride.	Burlington	Chittenden	Bikes & Pedestrian	https://kellybrushfoundation.org	https://www.facebook.com/kellybrushfoundation/		\N	\N	https://kellybrushfoundation.org/donate	\N	website	active	2026-08-06 20:16:54.295993	f	ok	\N	2026-08-23 09:47:23.918849
\.


--
-- Name: content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.content_id_seq', 1430, true);


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

\unrestrict mo4ORIXouFWiVoWZAbAcgXeGNQCbNuPYb0pf2kmAP0yP3VGT0ec1H1eNsDqlNwI

