PGDMP  "                    }           scrapnest_db     15.13 (Debian 15.13-1.pgdg120+1)    17.2 J    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    16384    scrapnest_db    DATABASE     w   CREATE DATABASE scrapnest_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE scrapnest_db;
                     user    false            �            1259    16441    faktury_sprzedazowe    TABLE     �   CREATE TABLE public.faktury_sprzedazowe (
    id integer NOT NULL,
    nr_faktury character varying(50) NOT NULL,
    data date NOT NULL,
    firma character varying(100) NOT NULL
);
 '   DROP TABLE public.faktury_sprzedazowe;
       public         heap r       user    false            �            1259    16421    faktury_zakupowe    TABLE     �   CREATE TABLE public.faktury_zakupowe (
    id integer NOT NULL,
    nr_faktury character varying(50) NOT NULL,
    data date NOT NULL,
    firma character varying(100) NOT NULL
);
 $   DROP TABLE public.faktury_zakupowe;
       public         heap r       user    false            �            1259    16461 
   formularze    TABLE     �   CREATE TABLE public.formularze (
    id integer NOT NULL,
    nr_formularza character varying(50) NOT NULL,
    data date NOT NULL
);
    DROP TABLE public.formularze;
       public         heap r       user    false            �            1259    16448    pozycje_faktury_sprzedazowe    TABLE     �   CREATE TABLE public.pozycje_faktury_sprzedazowe (
    id integer NOT NULL,
    faktura_id integer NOT NULL,
    metal character varying(50),
    waga numeric(10,2),
    CONSTRAINT pozycje_faktury_sprzedazowe_waga_check CHECK ((waga >= (0)::numeric))
);
 /   DROP TABLE public.pozycje_faktury_sprzedazowe;
       public         heap r       user    false            �            1259    16428    pozycje_faktury_zakupowe    TABLE     �   CREATE TABLE public.pozycje_faktury_zakupowe (
    id integer NOT NULL,
    faktura_id integer NOT NULL,
    metal character varying(50),
    waga numeric(10,2),
    CONSTRAINT pozycje_faktury_zakupowe_waga_check CHECK ((waga >= (0)::numeric))
);
 ,   DROP TABLE public.pozycje_faktury_zakupowe;
       public         heap r       user    false            �            1259    16468    pozycje_formularza    TABLE     �   CREATE TABLE public.pozycje_formularza (
    id integer NOT NULL,
    formularz_id integer NOT NULL,
    metal character varying(50),
    waga numeric(10,2),
    CONSTRAINT pozycje_formularza_waga_check CHECK ((waga >= (0)::numeric))
);
 &   DROP TABLE public.pozycje_formularza;
       public         heap r       user    false            �            1259    16543    sprzedaz_dzienna    VIEW     $  CREATE VIEW public.sprzedaz_dzienna AS
 SELECT fs.data,
    pfs.metal,
    sum(pfs.waga) AS suma_sprzedazy
   FROM (public.faktury_sprzedazowe fs
     JOIN public.pozycje_faktury_sprzedazowe pfs ON ((fs.id = pfs.faktura_id)))
  GROUP BY fs.data, pfs.metal
  ORDER BY fs.data DESC, pfs.metal;
 #   DROP VIEW public.sprzedaz_dzienna;
       public       v       user    false    223    223    221    221    223            �            1259    16569    zakupy_dzienne    VIEW     P  CREATE VIEW public.zakupy_dzienne AS
 SELECT wszystkie.data,
    wszystkie.metal,
    sum(wszystkie.waga) AS suma_zakupow
   FROM ( SELECT fz.data,
            TRIM(BOTH FROM lower((pfz.metal)::text)) AS metal,
            pfz.waga
           FROM (public.faktury_zakupowe fz
             JOIN public.pozycje_faktury_zakupowe pfz ON ((fz.id = pfz.faktura_id)))
          WHERE ((pfz.waga IS NOT NULL) AND (pfz.metal IS NOT NULL))
        UNION ALL
         SELECT ff.data,
            TRIM(BOTH FROM lower((pff.metal)::text)) AS metal,
            pff.waga
           FROM (public.formularze ff
             JOIN public.pozycje_formularza pff ON ((ff.id = pff.formularz_id)))
          WHERE ((pff.waga IS NOT NULL) AND (pff.metal IS NOT NULL))) wszystkie
  GROUP BY wszystkie.data, wszystkie.metal
  ORDER BY wszystkie.data DESC, wszystkie.metal;
 !   DROP VIEW public.zakupy_dzienne;
       public       v       user    false    219    227    217    225    225    217    219    219    227    227            �            1259    16574    stan_magazynowy    VIEW       CREATE VIEW public.stan_magazynowy AS
 WITH daty AS (
         SELECT zakupy_dzienne.data
           FROM public.zakupy_dzienne
        UNION
         SELECT sprzedaz_dzienna.data
           FROM public.sprzedaz_dzienna
        ), dni AS (
         SELECT (generate_series((min(daty.data))::timestamp with time zone, (max(daty.data))::timestamp with time zone, '1 day'::interval))::date AS data
           FROM daty
        ), metale AS (
         SELECT DISTINCT pozycje_faktury_zakupowe.metal
           FROM public.pozycje_faktury_zakupowe
        UNION
         SELECT DISTINCT pozycje_faktury_sprzedazowe.metal
           FROM public.pozycje_faktury_sprzedazowe
        ), kalendarz AS (
         SELECT d.data,
            m.metal
           FROM (dni d
             CROSS JOIN metale m)
        ), sumy_dzienne AS (
         SELECT k.data,
            k.metal,
            COALESCE(z.suma_zakupow, (0)::numeric) AS zakup,
            COALESCE(s.suma_sprzedazy, (0)::numeric) AS sprzedaz
           FROM ((kalendarz k
             LEFT JOIN public.zakupy_dzienne z ON (((z.data = k.data) AND (z.metal = (k.metal)::text))))
             LEFT JOIN public.sprzedaz_dzienna s ON (((s.data = k.data) AND ((s.metal)::text = (k.metal)::text))))
        ), narastajaco AS (
         SELECT sumy_dzienne.data,
            sumy_dzienne.metal,
            sumy_dzienne.zakup,
            sumy_dzienne.sprzedaz,
            sum((sumy_dzienne.zakup - sumy_dzienne.sprzedaz)) OVER (PARTITION BY sumy_dzienne.metal ORDER BY sumy_dzienne.data) AS stan_magazynowy
           FROM sumy_dzienne
        )
 SELECT narastajaco.data,
    narastajaco.metal,
    narastajaco.zakup,
    narastajaco.sprzedaz,
    narastajaco.stan_magazynowy
   FROM narastajaco
  ORDER BY narastajaco.data DESC, narastajaco.metal;
 "   DROP VIEW public.stan_magazynowy;
       public       v       user    false    231    232    232    232    231    231    223    219            �            1259    16579    stan_magazynowy_biezacy    VIEW     k  CREATE VIEW public.stan_magazynowy_biezacy AS
 SELECT stan_magazynowy.data,
    stan_magazynowy.metal,
    stan_magazynowy.zakup,
    stan_magazynowy.sprzedaz,
    stan_magazynowy.stan_magazynowy
   FROM public.stan_magazynowy
  WHERE (stan_magazynowy.data = ( SELECT max(stan_magazynowy_1.data) AS max
           FROM public.stan_magazynowy stan_magazynowy_1));
 *   DROP VIEW public.stan_magazynowy_biezacy;
       public       v       user    false    233    233    233    233    233            �            1259    16591    calkowita_masa    VIEW     �   CREATE VIEW public.calkowita_masa AS
 SELECT sum(stan_magazynowy_biezacy.stan_magazynowy) AS suma_wag
   FROM public.stan_magazynowy_biezacy;
 !   DROP VIEW public.calkowita_masa;
       public       v       user    false    234            �            1259    16605    dzienny_raport_metali    VIEW     (  CREATE VIEW public.dzienny_raport_metali AS
 SELECT COALESCE(z.data, s.data) AS data,
    COALESCE(z.metal, (s.metal)::text) AS metal,
    COALESCE((z.suma_zakupow)::text, 'brak'::text) AS suma_zakupow,
    COALESCE((s.suma_sprzedazy)::text, 'brak'::text) AS suma_sprzedazy,
    COALESCE(((s.suma_sprzedazy - z.suma_zakupow))::text, 'brak'::text) AS roznica_sprzedaz_zakup
   FROM (public.zakupy_dzienne z
     FULL JOIN public.sprzedaz_dzienna s ON (((z.data = s.data) AND (z.metal = (s.metal)::text))))
  ORDER BY COALESCE(z.metal, (s.metal)::text);
 (   DROP VIEW public.dzienny_raport_metali;
       public       v       user    false    232    232    231    231    232    231            �            1259    16440    faktury_sprzedazowe_id_seq    SEQUENCE     �   CREATE SEQUENCE public.faktury_sprzedazowe_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.faktury_sprzedazowe_id_seq;
       public               user    false    221            �           0    0    faktury_sprzedazowe_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.faktury_sprzedazowe_id_seq OWNED BY public.faktury_sprzedazowe.id;
          public               user    false    220            �            1259    16420    faktury_zakupowe_id_seq    SEQUENCE     �   CREATE SEQUENCE public.faktury_zakupowe_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.faktury_zakupowe_id_seq;
       public               user    false    217            �           0    0    faktury_zakupowe_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.faktury_zakupowe_id_seq OWNED BY public.faktury_zakupowe.id;
          public               user    false    216            �            1259    16460    formularze_id_seq    SEQUENCE     �   CREATE SEQUENCE public.formularze_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.formularze_id_seq;
       public               user    false    225            �           0    0    formularze_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.formularze_id_seq OWNED BY public.formularze.id;
          public               user    false    224            �            1259    16610    kontrahenci    TABLE     H  CREATE TABLE public.kontrahenci (
    id integer NOT NULL,
    nazwa_firmy character varying(100),
    bdo character varying(10),
    nip character(10),
    adres character varying(255),
    telefon character varying(20),
    mail character varying(100),
    CONSTRAINT kontrahenci_nip_check CHECK ((nip ~ '^\d{10}$'::text))
);
    DROP TABLE public.kontrahenci;
       public         heap r       user    false            �            1259    16609    kontrahenci_id_seq    SEQUENCE     �   CREATE SEQUENCE public.kontrahenci_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.kontrahenci_id_seq;
       public               user    false    238            �           0    0    kontrahenci_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.kontrahenci_id_seq OWNED BY public.kontrahenci.id;
          public               user    false    237            �            1259    16513    laczna_ilosc_metali    VIEW       CREATE VIEW public.laczna_ilosc_metali AS
 SELECT count(*) AS liczba_metali
   FROM ( SELECT DISTINCT TRIM(BOTH FROM lower((
                CASE
                    WHEN ((pozycje_formularza.metal)::text = 'żelazo i stal'::text) THEN 'żelazo'::character varying
                    ELSE pozycje_formularza.metal
                END)::text)) AS metal_norm
           FROM public.pozycje_formularza
        UNION
         SELECT DISTINCT TRIM(BOTH FROM lower((
                CASE
                    WHEN ((pozycje_faktury_zakupowe.metal)::text = 'żelazo i stal'::text) THEN 'żelazo'::character varying
                    ELSE pozycje_faktury_zakupowe.metal
                END)::text)) AS metal_norm
           FROM public.pozycje_faktury_zakupowe) unikalne_metale;
 &   DROP VIEW public.laczna_ilosc_metali;
       public       v       user    false    227    219            �            1259    16489    liczba_formularzy    VIEW     ^   CREATE VIEW public.liczba_formularzy AS
 SELECT count(*) AS liczba
   FROM public.formularze;
 $   DROP VIEW public.liczba_formularzy;
       public       v       user    false    225            �            1259    16617    liczba_odbiorcow    VIEW     ^   CREATE VIEW public.liczba_odbiorcow AS
 SELECT count(*) AS liczba
   FROM public.kontrahenci;
 #   DROP VIEW public.liczba_odbiorcow;
       public       v       user    false    238            �            1259    16522    ostatnie_sprzedaze    VIEW       CREATE VIEW public.ostatnie_sprzedaze AS
 SELECT f.data,
    f.firma AS odbiorca,
    initcap((p.metal)::text) AS metal,
    round(p.waga, 3) AS waga
   FROM (public.pozycje_faktury_sprzedazowe p
     JOIN public.faktury_sprzedazowe f ON ((p.faktura_id = f.id)))
  ORDER BY f.data DESC;
 %   DROP VIEW public.ostatnie_sprzedaze;
       public       v       user    false    221    221    221    223    223    223            �            1259    16447 "   pozycje_faktury_sprzedazowe_id_seq    SEQUENCE     �   CREATE SEQUENCE public.pozycje_faktury_sprzedazowe_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.pozycje_faktury_sprzedazowe_id_seq;
       public               user    false    223            �           0    0 "   pozycje_faktury_sprzedazowe_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.pozycje_faktury_sprzedazowe_id_seq OWNED BY public.pozycje_faktury_sprzedazowe.id;
          public               user    false    222            �            1259    16427    pozycje_faktury_zakupowe_id_seq    SEQUENCE     �   CREATE SEQUENCE public.pozycje_faktury_zakupowe_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.pozycje_faktury_zakupowe_id_seq;
       public               user    false    219            �           0    0    pozycje_faktury_zakupowe_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.pozycje_faktury_zakupowe_id_seq OWNED BY public.pozycje_faktury_zakupowe.id;
          public               user    false    218            �            1259    16467    pozycje_formularza_id_seq    SEQUENCE     �   CREATE SEQUENCE public.pozycje_formularza_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.pozycje_formularza_id_seq;
       public               user    false    227            �           0    0    pozycje_formularza_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.pozycje_formularza_id_seq OWNED BY public.pozycje_formularza.id;
          public               user    false    226            �            1259    16390    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    imie text NOT NULL,
    nazwisko text NOT NULL,
    email text NOT NULL,
    haslo text NOT NULL,
    rola text NOT NULL
);
    DROP TABLE public.users;
       public         heap r       user    false            �            1259    16389    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public               user    false    215            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public               user    false    214            �           2604    16444    faktury_sprzedazowe id    DEFAULT     �   ALTER TABLE ONLY public.faktury_sprzedazowe ALTER COLUMN id SET DEFAULT nextval('public.faktury_sprzedazowe_id_seq'::regclass);
 E   ALTER TABLE public.faktury_sprzedazowe ALTER COLUMN id DROP DEFAULT;
       public               user    false    221    220    221            �           2604    16424    faktury_zakupowe id    DEFAULT     z   ALTER TABLE ONLY public.faktury_zakupowe ALTER COLUMN id SET DEFAULT nextval('public.faktury_zakupowe_id_seq'::regclass);
 B   ALTER TABLE public.faktury_zakupowe ALTER COLUMN id DROP DEFAULT;
       public               user    false    217    216    217            �           2604    16464    formularze id    DEFAULT     n   ALTER TABLE ONLY public.formularze ALTER COLUMN id SET DEFAULT nextval('public.formularze_id_seq'::regclass);
 <   ALTER TABLE public.formularze ALTER COLUMN id DROP DEFAULT;
       public               user    false    224    225    225            �           2604    16613    kontrahenci id    DEFAULT     p   ALTER TABLE ONLY public.kontrahenci ALTER COLUMN id SET DEFAULT nextval('public.kontrahenci_id_seq'::regclass);
 =   ALTER TABLE public.kontrahenci ALTER COLUMN id DROP DEFAULT;
       public               user    false    237    238    238            �           2604    16451    pozycje_faktury_sprzedazowe id    DEFAULT     �   ALTER TABLE ONLY public.pozycje_faktury_sprzedazowe ALTER COLUMN id SET DEFAULT nextval('public.pozycje_faktury_sprzedazowe_id_seq'::regclass);
 M   ALTER TABLE public.pozycje_faktury_sprzedazowe ALTER COLUMN id DROP DEFAULT;
       public               user    false    223    222    223            �           2604    16431    pozycje_faktury_zakupowe id    DEFAULT     �   ALTER TABLE ONLY public.pozycje_faktury_zakupowe ALTER COLUMN id SET DEFAULT nextval('public.pozycje_faktury_zakupowe_id_seq'::regclass);
 J   ALTER TABLE public.pozycje_faktury_zakupowe ALTER COLUMN id DROP DEFAULT;
       public               user    false    218    219    219            �           2604    16471    pozycje_formularza id    DEFAULT     ~   ALTER TABLE ONLY public.pozycje_formularza ALTER COLUMN id SET DEFAULT nextval('public.pozycje_formularza_id_seq'::regclass);
 D   ALTER TABLE public.pozycje_formularza ALTER COLUMN id DROP DEFAULT;
       public               user    false    226    227    227            �           2604    16393    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public               user    false    215    214    215            x          0    16441    faktury_sprzedazowe 
   TABLE DATA           J   COPY public.faktury_sprzedazowe (id, nr_faktury, data, firma) FROM stdin;
    public               user    false    221   �j       t          0    16421    faktury_zakupowe 
   TABLE DATA           G   COPY public.faktury_zakupowe (id, nr_faktury, data, firma) FROM stdin;
    public               user    false    217   k       |          0    16461 
   formularze 
   TABLE DATA           =   COPY public.formularze (id, nr_formularza, data) FROM stdin;
    public               user    false    225   �k       �          0    16610    kontrahenci 
   TABLE DATA           V   COPY public.kontrahenci (id, nazwa_firmy, bdo, nip, adres, telefon, mail) FROM stdin;
    public               user    false    238   �l       z          0    16448    pozycje_faktury_sprzedazowe 
   TABLE DATA           R   COPY public.pozycje_faktury_sprzedazowe (id, faktura_id, metal, waga) FROM stdin;
    public               user    false    223   �m       v          0    16428    pozycje_faktury_zakupowe 
   TABLE DATA           O   COPY public.pozycje_faktury_zakupowe (id, faktura_id, metal, waga) FROM stdin;
    public               user    false    219   Fn       ~          0    16468    pozycje_formularza 
   TABLE DATA           K   COPY public.pozycje_formularza (id, formularz_id, metal, waga) FROM stdin;
    public               user    false    227   -o       r          0    16390    users 
   TABLE DATA           G   COPY public.users (id, imie, nazwisko, email, haslo, rola) FROM stdin;
    public               user    false    215   Lq       �           0    0    faktury_sprzedazowe_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.faktury_sprzedazowe_id_seq', 12, true);
          public               user    false    220            �           0    0    faktury_zakupowe_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.faktury_zakupowe_id_seq', 27, true);
          public               user    false    216            �           0    0    formularze_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.formularze_id_seq', 44, true);
          public               user    false    224            �           0    0    kontrahenci_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.kontrahenci_id_seq', 4, true);
          public               user    false    237            �           0    0 "   pozycje_faktury_sprzedazowe_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.pozycje_faktury_sprzedazowe_id_seq', 54, true);
          public               user    false    222            �           0    0    pozycje_faktury_zakupowe_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.pozycje_faktury_zakupowe_id_seq', 43, true);
          public               user    false    218            �           0    0    pozycje_formularza_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.pozycje_formularza_id_seq', 187, true);
          public               user    false    226            �           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 45, true);
          public               user    false    214            �           2606    16446 ,   faktury_sprzedazowe faktury_sprzedazowe_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.faktury_sprzedazowe
    ADD CONSTRAINT faktury_sprzedazowe_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.faktury_sprzedazowe DROP CONSTRAINT faktury_sprzedazowe_pkey;
       public                 user    false    221            �           2606    16426 &   faktury_zakupowe faktury_zakupowe_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.faktury_zakupowe
    ADD CONSTRAINT faktury_zakupowe_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.faktury_zakupowe DROP CONSTRAINT faktury_zakupowe_pkey;
       public                 user    false    217            �           2606    16466    formularze formularze_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.formularze
    ADD CONSTRAINT formularze_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.formularze DROP CONSTRAINT formularze_pkey;
       public                 user    false    225            �           2606    16616    kontrahenci kontrahenci_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.kontrahenci
    ADD CONSTRAINT kontrahenci_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.kontrahenci DROP CONSTRAINT kontrahenci_pkey;
       public                 user    false    238            �           2606    16454 <   pozycje_faktury_sprzedazowe pozycje_faktury_sprzedazowe_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.pozycje_faktury_sprzedazowe
    ADD CONSTRAINT pozycje_faktury_sprzedazowe_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.pozycje_faktury_sprzedazowe DROP CONSTRAINT pozycje_faktury_sprzedazowe_pkey;
       public                 user    false    223            �           2606    16434 6   pozycje_faktury_zakupowe pozycje_faktury_zakupowe_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.pozycje_faktury_zakupowe
    ADD CONSTRAINT pozycje_faktury_zakupowe_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.pozycje_faktury_zakupowe DROP CONSTRAINT pozycje_faktury_zakupowe_pkey;
       public                 user    false    219            �           2606    16474 *   pozycje_formularza pozycje_formularza_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.pozycje_formularza
    ADD CONSTRAINT pozycje_formularza_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.pozycje_formularza DROP CONSTRAINT pozycje_formularza_pkey;
       public                 user    false    227            �           2606    16399    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public                 user    false    215            �           2606    16397    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 user    false    215            �           2606    16455 G   pozycje_faktury_sprzedazowe pozycje_faktury_sprzedazowe_faktura_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pozycje_faktury_sprzedazowe
    ADD CONSTRAINT pozycje_faktury_sprzedazowe_faktura_id_fkey FOREIGN KEY (faktura_id) REFERENCES public.faktury_sprzedazowe(id) ON DELETE CASCADE;
 q   ALTER TABLE ONLY public.pozycje_faktury_sprzedazowe DROP CONSTRAINT pozycje_faktury_sprzedazowe_faktura_id_fkey;
       public               user    false    3277    223    221            �           2606    16435 A   pozycje_faktury_zakupowe pozycje_faktury_zakupowe_faktura_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pozycje_faktury_zakupowe
    ADD CONSTRAINT pozycje_faktury_zakupowe_faktura_id_fkey FOREIGN KEY (faktura_id) REFERENCES public.faktury_zakupowe(id) ON DELETE CASCADE;
 k   ALTER TABLE ONLY public.pozycje_faktury_zakupowe DROP CONSTRAINT pozycje_faktury_zakupowe_faktura_id_fkey;
       public               user    false    217    219    3273            �           2606    16475 7   pozycje_formularza pozycje_formularza_formularz_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pozycje_formularza
    ADD CONSTRAINT pozycje_formularza_formularz_id_fkey FOREIGN KEY (formularz_id) REFERENCES public.formularze(id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.pozycje_formularza DROP CONSTRAINT pozycje_formularza_formularz_id_fkey;
       public               user    false    3281    225    227            x   }   x�3�t�V0�7��70�7202����F���%�9\&pU���,A�s�L!��p(
.J,�L,J�2��3&���Δ�:K�:3܎y����`56�Pel3���U�ʀ���qqq �
Lw      t   �   x����
�0����&i�u�ɓ�e���c���B[�&x����G�#y����3���x-��9�2ߞ�K ��VBL��8w��}ٮ�~wL��=X������������$����l�����C����M` ����"�%z/�j��4!h^3��L@>�Y��q^�^o'���B��      |   �   x�u�[��0�oi/��4~��_ǵ�U�B 98��=e_�qqù�J}Q�P��v�1e�jEjAU��V���5��ڠ&4S�ԂVj��̴���i>��p�A��pO��N3h�N3h�N3hQ�������=�.���,<Oi�=��7���`T�!��~�~ȋ��b�D��ڍ?�{*�z6�B�^(P/��#�3��*      �   �   x�5��N�@���)�W���,;�Qh,�ژ�l�!,pA.D;}%:[�{9�ũ�L�}�����s�|-GD����s�$�X����R{E�V97Z�?~|����*5+S:e��Sh]�UC��3��vH��������8G;�q\������ܒ��o�e��+d��IQ՝ob�>t���1�����3 #�p5̍���+�eN�ؾ����
}@e�J��:����ފ,�� ��Q�      z   �   x�e�;�0D��)r˟�w���1A2n�s)DI�ŢD(J�Z�������~~A�0�IkN�T3�4���J�<����a~clS���#�⑊E��A�~C�B�p:z��{-��F��Oԫx�k��>�{�B�/Y�C�      v   �   x�e�;�0���=��ܥQ�T�,�Tձܫ��eC_��;!�����U0B�B$d`v�3d;R@�kWe���32�w�K	�(�qw�7S��
��>��mP:f�Q���*㧪����K�,��,�<����R���U����\��>�n���$8^S/����wV3��v������Kn���X�r|�w�|{��$����k�$�v��}      ~     x�m�Kn�0D׭S����]��^��Lf3�\*�2�W�(����>���?d,bN.�����nvnJI���|�,o��"���I??^Χ����t�u:K���Q9f�^���]﯋�9�)�&�� r�	�H�{������h��6�#���#�uVP�/�Boœ���\ ��͋�K	�:�at$�UT�D��sDob��خR�ƞP�n�*��/�YX$c���<sU)��&[3iW��ZHF��S����)�Α=�]�w�F����@���6{��h�]Ɋ�qpuU��]+友�I�3c�sGWI�P�Od�ѼG�t,�y��HD�h���=�8�Cy���M�x�FEB?N�����3���|b4j���f�i�}�T7<�q�n��th(�d���tP�n�U���4���`6Ӱ���J��ՐG6Tm-:�����S�k��� �|8�>o���Ќ=g��#����GS|M�����((��z���,6����G
߾M��z$���%������<M�?3��L      r   �  x���˒�Z���s���-��( ��%wP�0;���o��߫��Nm�,s-#�"��?��Ϣ������=E~����:Vp	0��vt/��!6��c֥���tz�K�rU�]O������Ǉ�p1�̭FD*:7������g��Q
�E�IYZ8�����R��-��X��tZ�,���#��7��p$sw��o8�HnY�Q�"�[���^%.� o��)�'��N���px�Lv��3��%]��I�G�lQ��O�m����I���So��+�.r�y=�K~�s\C�gt;ܶQS1��DK]ѡT�w}e��2͐{��T�#�m'X��Vȯ?��	�_����C���É9Ol�S-�\k�`�r<٨u�Vx�(4�9#����֗��ܵlf<���wS8ɹw���xH<��ޜ��Յ�V��1v�!�G/�4���͵(z��F���uy����v0�j^�d~���O��}��d(�V|�\O��GC�40�:����п����ݵQ�������<�z�(b�5����_��R}�[����|���z%bIϮLtymf����{,��tۡ&N�)	�B���Q_��:ؤ^�E�h�t��'�놸EWAĺjE�[��;J�^PV,mM4�"���&�V���W9����L�&H�<A�����e8�e\���ƌ�˞�X\e�*']{�lAȨ�8��r�QC=�m���.�����d��Ҫ�4�6l+A=�\��p�%�~�<���CvycKŷ���ֳ^$V��k�~�{�=˺��mWr��b�g�6��+'�����K�X�:�"=��fX
�Nj6W���|B�� �?��/�,T�Ԁ9���`��C��=��*���;gTe�u�����l~4�I����x �c��j�ȣA�v��NS�ew�ɒ�:fؓ�m\,�B34͐�G
[b�q��͟�/9]d���b&KN�N��([�8���%X��6��Y�����mG:��ɡ^+W��"QD.�h�6[������_���B�	�s��#� Xj��C5/�����Q�=��⡲q�`�ׁBb�	j�,۫ų����$�䱥�p\�A�	��政.N�-�mLfc�1�iZ���%�5�#5����<���$�a�y���u��`7���y��+b48G:�B����Z�����]
{7���5���9�╛|υM~�&���p���CH�?
��B��}4���s�>w'�6�m�}SŊ�N�"yEFNz�4% �� � ���1F��I��0��ю��Q$5��N�E�/��H�x_!���c߂��0�r\�ư��<8	�G��Z�&['�#�s��{�[�Y_��d��wI?F�S��q������%K�l�\9�PC(Q������;>�7V��\Y&_��
�x{{�r�*�     