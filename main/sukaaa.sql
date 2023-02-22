PGDMP         8                {            postgres    15.1    15.1 A    i           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            j           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            k           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            l           1262    5    postgres    DATABASE     |   CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE postgres;
                postgres    false            m           0    0    DATABASE postgres    COMMENT     N   COMMENT ON DATABASE postgres IS 'default administrative connection database';
                   postgres    false    3436                        3079    16384 	   adminpack 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;
    DROP EXTENSION adminpack;
                   false            n           0    0    EXTENSION adminpack    COMMENT     M   COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';
                        false    2            �            1255    16600    add_to_table() 	   PROCEDURE       CREATE PROCEDURE public.add_to_table()
    LANGUAGE plpgsql
    AS $$
DECLARE
i integer:=1;
b bigint;

BEGIN
	FOR i IN SELECT COUNT(workers.id) FROM workers LOOP
	 b=summ_workers(i);
	INSERT INTO temp_useful_workers1(id, summa) VALUES (i,b);
	END LOOP;
END;
$$;
 &   DROP PROCEDURE public.add_to_table();
       public          postgres    false            �            1255    16398    available_quantity_changer()    FUNCTION     V  CREATE FUNCTION public.available_quantity_changer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE products SET available_quantity = available_quantity - 1
		WHERE
			id IN(SELECT works_products.product_id FROM works_products, works_in_process WHERE works_in_process.work_id = works_products.work_id);
		RETURN NEW;
	END;
$$;
 3   DROP FUNCTION public.available_quantity_changer();
       public          postgres    false            �            1255    16399 *   available_quantity_changer_before_delete()    FUNCTION     B  CREATE FUNCTION public.available_quantity_changer_before_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE ready_products SET available_quantity = available_quantity + 1
		WHERE
			id IN(SELECT works.id FROM works, works_in_process WHERE works.id = works_in_process.work_id);
		RETURN NEW;
	END;
$$;
 A   DROP FUNCTION public.available_quantity_changer_before_delete();
       public          postgres    false                        1255    16720    best_worker()    FUNCTION     V  CREATE FUNCTION public.best_worker() RETURNS TABLE(imya text, res numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
CREATE TABLE promejutok(id int, worker_id int, worker_result numeric);
FOR i IN 1..(SELECT COUNT(*) FROM workers) LOOP
	INSERT INTO promejutok(id, worker_id, worker_result) VALUES(i, i, (SELECT * FROM summ_workers(i)));
END LOOP;
RETURN QUERY SELECT workers.name_surname as imya, promejutok.worker_result as res FROM workers, promejutok 
WHERE promejutok.worker_result = (SELECT max(worker_result) FROM promejutok) AND promejutok.worker_id = workers.id;
DROP TABLE promejutok;
END;
$$;
 $   DROP FUNCTION public.best_worker();
       public          postgres    false            �            1255    16742    best_worker(integer)    FUNCTION     Y  CREATE FUNCTION public.best_worker(workers_count integer) RETURNS TABLE(imya text, res numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
CREATE TABLE promejutok(id int, worker_id int, worker_result numeric);
FOR i IN 1..workers_count LOOP
	INSERT INTO promejutok(id, worker_id, worker_result) VALUES(i, i, (SELECT * FROM summ_workers(i)));
END LOOP;
RETURN QUERY SELECT workers.name_surname as imya, promejutok.worker_result as res FROM workers, promejutok WHERE promejutok.worker_result = (SELECT max(worker_result) FROM promejutok) AND promejutok.worker_id = workers.id;
DROP TABLE promejutok;
END;
$$;
 9   DROP FUNCTION public.best_worker(workers_count integer);
       public          postgres    false            �            1255    16550    check_max()    FUNCTION     E  CREATE FUNCTION public.check_max() RETURNS TABLE(valueintable bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN
return query
	SELECT sum(available_quantity) as valueintable FROM products;
	IF valueintable < 1000 AND valueintable > 250 THEN
		RAISE NOTICE 'stock is full';
	ELSE
		RAISE NOTICE 'stock is low';
	END IF;
	
END;
$$;
 "   DROP FUNCTION public.check_max();
       public          postgres    false            �            1255    16568    summ_workers(integer)    FUNCTION     �  CREATE FUNCTION public.summ_workers(a integer) RETURNS TABLE(b numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT sum(summa) as itogo
from (select count(*)*ready_products.selling_price_per_unit as summa
	  FROM works_in_process
	  join ready_products on ready_products.id = works_in_process.ready_product_id
	  where works_in_process.worker_id=a
	  group by ready_products.selling_price_per_unit) as summa_table;
END;
$$;
 .   DROP FUNCTION public.summ_workers(a integer);
       public          postgres    false            �            1255    16524    sumproducts()    FUNCTION     �   CREATE FUNCTION public.sumproducts() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	total integer;
BEGIN
SELECT SUM(available_quantity) into total FROM ready_products;
RETURN total;
END;
$$;
 $   DROP FUNCTION public.sumproducts();
       public          postgres    false            �            1259    16414    ready_products_id_inc    SEQUENCE        CREATE SEQUENCE public.ready_products_id_inc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 100
    CACHE 1;
 ,   DROP SEQUENCE public.ready_products_id_inc;
       public          postgres    false            �            1259    16415    ready_products    TABLE     �   CREATE TABLE public.ready_products (
    id integer DEFAULT nextval('public.ready_products_id_inc'::regclass) NOT NULL,
    name text NOT NULL,
    selling_price_per_unit integer NOT NULL,
    available_quantity integer NOT NULL
);
 "   DROP TABLE public.ready_products;
       public         heap    postgres    false    223            �            1259    16520    check_all_sum_on_stock    VIEW     �   CREATE VIEW public.check_all_sum_on_stock AS
 SELECT (sum(ready_products.selling_price_per_unit) * sum(ready_products.available_quantity)) AS "Цена_готовой_продукции"
   FROM public.ready_products;
 )   DROP VIEW public.check_all_sum_on_stock;
       public          postgres    false    224    224            �            1259    16508    check_available_stock    VIEW     *  CREATE VIEW public.check_available_stock AS
 SELECT ready_products.name,
    'Кол-во пар на складе:'::text AS "?column?",
    sum(ready_products.available_quantity) AS sum
   FROM public.ready_products
  WHERE (ready_products.available_quantity > 0)
  GROUP BY ready_products.name;
 (   DROP VIEW public.check_available_stock;
       public          postgres    false    224    224            �            1259    16400    products_id_inc    SEQUENCE     y   CREATE SEQUENCE public.products_id_inc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 100
    CACHE 1;
 &   DROP SEQUENCE public.products_id_inc;
       public          postgres    false            �            1259    16401    products    TABLE     �   CREATE TABLE public.products (
    id integer DEFAULT nextval('public.products_id_inc'::regclass) NOT NULL,
    name text NOT NULL,
    purchase_price_per_unit integer NOT NULL,
    available_quantity integer NOT NULL,
    provider_id integer NOT NULL
);
    DROP TABLE public.products;
       public         heap    postgres    false    219            �            1259    16516    check_available_stock_res    VIEW     �   CREATE VIEW public.check_available_stock_res AS
 SELECT products.name,
    products.available_quantity,
    (products.purchase_price_per_unit * products.available_quantity) AS "сумма"
   FROM public.products;
 ,   DROP VIEW public.check_available_stock_res;
       public          postgres    false    220    220    220            �            1259    16438    works_in_process_id_inc    SEQUENCE     �   CREATE SEQUENCE public.works_in_process_id_inc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 10000
    CACHE 1;
 .   DROP SEQUENCE public.works_in_process_id_inc;
       public          postgres    false            �            1259    16439    works_in_process    TABLE     �   CREATE TABLE public.works_in_process (
    id integer DEFAULT nextval('public.works_in_process_id_inc'::regclass) NOT NULL,
    name text NOT NULL,
    work_id integer NOT NULL,
    ready_product_id integer NOT NULL,
    worker_id integer
);
 $   DROP TABLE public.works_in_process;
       public         heap    postgres    false    230            �            1259    16504    get_info_about_works_in_process    VIEW     �   CREATE VIEW public.get_info_about_works_in_process AS
 SELECT works_in_process.name,
    count(works_in_process.name) AS count
   FROM public.works_in_process
  GROUP BY works_in_process.name
  ORDER BY (count(works_in_process.name));
 2   DROP VIEW public.get_info_about_works_in_process;
       public          postgres    false    231            �            1259    16407    providers_id_inc    SEQUENCE     z   CREATE SEQUENCE public.providers_id_inc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 100
    CACHE 1;
 '   DROP SEQUENCE public.providers_id_inc;
       public          postgres    false            �            1259    16408 	   providers    TABLE     �   CREATE TABLE public.providers (
    id integer DEFAULT nextval('public.providers_id_inc'::regclass) NOT NULL,
    name text NOT NULL,
    number text NOT NULL
);
    DROP TABLE public.providers;
       public         heap    postgres    false    221            �            1259    16512    suppliers_and_supplies    VIEW     �   CREATE VIEW public.suppliers_and_supplies AS
 SELECT products.name AS "название_продукта",
    providers.name AS "поставщик"
   FROM public.products,
    public.providers
  WHERE (products.id = providers.id);
 )   DROP VIEW public.suppliers_and_supplies;
       public          postgres    false    220    220    222    222            �            1259    16421    workers_id_inc    SEQUENCE     x   CREATE SEQUENCE public.workers_id_inc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 100
    CACHE 1;
 %   DROP SEQUENCE public.workers_id_inc;
       public          postgres    false            �            1259    16422    workers    TABLE     �   CREATE TABLE public.workers (
    id integer DEFAULT nextval('public.workers_id_inc'::regclass) NOT NULL,
    name_surname text NOT NULL,
    number text NOT NULL
);
    DROP TABLE public.workers;
       public         heap    postgres    false    225            �            1259    16428    workers_works    TABLE     d   CREATE TABLE public.workers_works (
    worker_id integer NOT NULL,
    work_id integer NOT NULL
);
 !   DROP TABLE public.workers_works;
       public         heap    postgres    false            �            1259    16431    works_id_inc    SEQUENCE     v   CREATE SEQUENCE public.works_id_inc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 100
    CACHE 1;
 #   DROP SEQUENCE public.works_id_inc;
       public          postgres    false            �            1259    16432    works    TABLE     �   CREATE TABLE public.works (
    id integer DEFAULT nextval('public.works_id_inc'::regclass) NOT NULL,
    name text NOT NULL
);
    DROP TABLE public.works;
       public         heap    postgres    false    228            �            1259    16445    works_products    TABLE     f   CREATE TABLE public.works_products (
    work_id integer NOT NULL,
    product_id integer NOT NULL
);
 "   DROP TABLE public.works_products;
       public         heap    postgres    false            Z          0    16401    products 
   TABLE DATA           f   COPY public.products (id, name, purchase_price_per_unit, available_quantity, provider_id) FROM stdin;
    public          postgres    false    220   W       \          0    16408 	   providers 
   TABLE DATA           5   COPY public.providers (id, name, number) FROM stdin;
    public          postgres    false    222   �W       ^          0    16415    ready_products 
   TABLE DATA           ^   COPY public.ready_products (id, name, selling_price_per_unit, available_quantity) FROM stdin;
    public          postgres    false    224   �X       `          0    16422    workers 
   TABLE DATA           ;   COPY public.workers (id, name_surname, number) FROM stdin;
    public          postgres    false    226   gY       a          0    16428    workers_works 
   TABLE DATA           ;   COPY public.workers_works (worker_id, work_id) FROM stdin;
    public          postgres    false    227   Z       c          0    16432    works 
   TABLE DATA           )   COPY public.works (id, name) FROM stdin;
    public          postgres    false    229   7Z       e          0    16439    works_in_process 
   TABLE DATA           Z   COPY public.works_in_process (id, name, work_id, ready_product_id, worker_id) FROM stdin;
    public          postgres    false    231   �Z       f          0    16445    works_products 
   TABLE DATA           =   COPY public.works_products (work_id, product_id) FROM stdin;
    public          postgres    false    232   ag       o           0    0    products_id_inc    SEQUENCE SET     >   SELECT pg_catalog.setval('public.products_id_inc', 10, true);
          public          postgres    false    219            p           0    0    providers_id_inc    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.providers_id_inc', 10, true);
          public          postgres    false    221            q           0    0    ready_products_id_inc    SEQUENCE SET     C   SELECT pg_catalog.setval('public.ready_products_id_inc', 4, true);
          public          postgres    false    223            r           0    0    workers_id_inc    SEQUENCE SET     <   SELECT pg_catalog.setval('public.workers_id_inc', 4, true);
          public          postgres    false    225            s           0    0    works_id_inc    SEQUENCE SET     :   SELECT pg_catalog.setval('public.works_id_inc', 4, true);
          public          postgres    false    228            t           0    0    works_in_process_id_inc    SEQUENCE SET     H   SELECT pg_catalog.setval('public.works_in_process_id_inc', 1001, true);
          public          postgres    false    230            �           2606    16449    products products_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.products DROP CONSTRAINT products_pkey;
       public            postgres    false    220            �           2606    16451    providers providers_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.providers DROP CONSTRAINT providers_pkey;
       public            postgres    false    222            �           2606    16453 "   ready_products ready_products_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.ready_products
    ADD CONSTRAINT ready_products_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.ready_products DROP CONSTRAINT ready_products_pkey;
       public            postgres    false    224            �           2606    16455    workers workers_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.workers DROP CONSTRAINT workers_pkey;
       public            postgres    false    226            �           2606    16457     workers_works workers_works_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.workers_works
    ADD CONSTRAINT workers_works_pkey PRIMARY KEY (worker_id, work_id);
 J   ALTER TABLE ONLY public.workers_works DROP CONSTRAINT workers_works_pkey;
       public            postgres    false    227    227            �           2606    16459 &   works_in_process works_in_process_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.works_in_process
    ADD CONSTRAINT works_in_process_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.works_in_process DROP CONSTRAINT works_in_process_pkey;
       public            postgres    false    231            �           2606    16461    works works_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.works DROP CONSTRAINT works_pkey;
       public            postgres    false    229            �           2606    16463 "   works_products works_products_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.works_products
    ADD CONSTRAINT works_products_pkey PRIMARY KEY (work_id, product_id);
 L   ALTER TABLE ONLY public.works_products DROP CONSTRAINT works_products_pkey;
       public            postgres    false    232    232            �           2620    16464 5   works_in_process available_quantity_changer_after_add    TRIGGER     �   CREATE TRIGGER available_quantity_changer_after_add AFTER INSERT ON public.works_in_process FOR EACH ROW EXECUTE FUNCTION public.available_quantity_changer();
 N   DROP TRIGGER available_quantity_changer_after_add ON public.works_in_process;
       public          postgres    false    231    238            �           2606    16555    works_in_process fk_works_in    FK CONSTRAINT        ALTER TABLE ONLY public.works_in_process
    ADD CONSTRAINT fk_works_in FOREIGN KEY (worker_id) REFERENCES public.workers(id);
 F   ALTER TABLE ONLY public.works_in_process DROP CONSTRAINT fk_works_in;
       public          postgres    false    226    231    3252            �           2606    16465 "   products products_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.providers(id);
 L   ALTER TABLE ONLY public.products DROP CONSTRAINT products_provider_id_fkey;
       public          postgres    false    220    222    3248            �           2606    16470 (   workers_works workers_works_work_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.workers_works
    ADD CONSTRAINT workers_works_work_id_fkey FOREIGN KEY (work_id) REFERENCES public.works(id);
 R   ALTER TABLE ONLY public.workers_works DROP CONSTRAINT workers_works_work_id_fkey;
       public          postgres    false    229    3256    227            �           2606    16475 *   workers_works workers_works_worker_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.workers_works
    ADD CONSTRAINT workers_works_worker_id_fkey FOREIGN KEY (worker_id) REFERENCES public.workers(id);
 T   ALTER TABLE ONLY public.workers_works DROP CONSTRAINT workers_works_worker_id_fkey;
       public          postgres    false    226    3252    227            �           2606    16480 7   works_in_process works_in_process_ready_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.works_in_process
    ADD CONSTRAINT works_in_process_ready_product_id_fkey FOREIGN KEY (ready_product_id) REFERENCES public.ready_products(id);
 a   ALTER TABLE ONLY public.works_in_process DROP CONSTRAINT works_in_process_ready_product_id_fkey;
       public          postgres    false    3250    224    231            �           2606    16485 .   works_in_process works_in_process_work_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.works_in_process
    ADD CONSTRAINT works_in_process_work_id_fkey FOREIGN KEY (work_id) REFERENCES public.works(id);
 X   ALTER TABLE ONLY public.works_in_process DROP CONSTRAINT works_in_process_work_id_fkey;
       public          postgres    false    229    231    3256            �           2606    16490 -   works_products works_products_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.works_products
    ADD CONSTRAINT works_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
 W   ALTER TABLE ONLY public.works_products DROP CONSTRAINT works_products_product_id_fkey;
       public          postgres    false    232    3246    220            �           2606    16495 *   works_products works_products_work_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.works_products
    ADD CONSTRAINT works_products_work_id_fkey FOREIGN KEY (work_id) REFERENCES public.works(id);
 T   ALTER TABLE ONLY public.works_products DROP CONSTRAINT works_products_work_id_fkey;
       public          postgres    false    232    229    3256            Z   �   x�]���0���=�%M��.�"$��>`{#�C���o���ۉ���oZD���r4�h-��3؈li��Wa�G��w��_�*v*�,�zNK�h��~z���ZY0:4�i����90SaO+Z���\����;ˊ��3�fwq��x�/�#>�%~c!���Z&KZ�;��2��X���Ҍ��g �Y��;      \   �   x�u��M�@D���pF�ޝ��� #��!h��¤P?#���&q�E�������x��`j������hr�;o����`��&
k(�S.9&I�tmu��X��s>��'T��;{=�<�х|pf������.D�H���c��_���A��=�ۖ������z��Y��-�+n9貭}j>�V�b�X�ڈ��_LIs��J�1�oV�!�(�5���^�O��)��| ilɌ      ^   [   x�5˹�0D�x��n(2:p 	�dZ��; �7�	O:�k�+���e��K|]|�iϬQc��w�P�:ᢃ�|��t�\P)w      `   �   x�5�1�0k�+��;�E�-�������������V����	w<1��oL1�u��]�{ӊs�6�{�3��Â!�3�T���ޫ��VjH�����?'"�!�\�)�����`���8�0mVD��Xt      a   #   x�3�4�2�4�2�4b.c ��7�c���� C��      c   `   x�}��� �Ͼ)��ğqԛ,�D%��B��o�|��vvdܸ��A4(������)}ECBT�q�P�h��tUUM��v>s��/�L���.�n�      e   �  x�}�K�-;E����sa0<A�Ѓ >	�PwFD4��r�z�t�ω��r���?����w������_���������ȿ������~�/���-��g��������?����>���_~��������k���9?Gc���:������+h���Qǧ�;lw��i�=ضh�m�:n�w�;h������_Ǎ�v�����C��E�y]r6?���d-z��=t�[��g���=$oC�mϼ�5�[�����"o�6%oS���ۄ�E��mJޢ�����6e�M����"o�6?K�$o����-�[�Jޖ�-�y[��X������myۘ�=%��v�Hn�[�D�ۖ��[���������v���[�D��#y��"o�6>&��$o�cϼE̛I��=��xw��f�N�3o�㸿y��밿y�7���%o.y��ϼ�g�����{"�/�\��E���}I���I�*�׾p޵/�x�V�V#
νvCJ||���]���d���0�Ur��K�������\�EΥKSb���%��d ��A��$�b:6斦�Ҕ\��3��sy�K6��l�4�$`�L{#L<�&����(�d�*��1�46���2yr�n�ɗz{x�L��}��@�����&{ �6��FT��X�=�ͯ�`�P�&��̋�G�n�	覽�&/"��pbJ8y_�*H���N�RN6V�$��7H]c�t��u���7�d��w26��x���e�<��')�4���ƞ|0��7�d��o��qc.��OW��7�7��@����w��7�d\c��>���f��1p��7��(�}�{����ӕ}:�O�ا?t��}�Ne�l,����jn��0�����=p��7���`^�7�ĸ�}��>�8b�^�O'��>�Ke�Z�Kb��ƾ�;Q���*��>٬�$���t�p��>y'��7�Db���>y'����r:�O���+�d�b���>�f���쓍��J쓱UDU�I����>٬�R�'+���>�G�I��O*��tf���ӕ}��\fl�/o�I����}��R٧+�d�B+��>٬�R�'�ا��wr�O�I���>��I��>�8���f���C�g(��}���`�g��wǎ7�������e�h�t����q�O�)���b^b�l�B��O��Xc��P��>��}�O6��7�R5����Z�P�g(��*��>�,�r(��˒�π���x�O^�5v��3�}ƛ}b��>C�WC�'�P엃�'�u^���}װ��>�8�b�7��E�?��3H�o��"��}��OĮ�gp=k��3H�o��#�e�A�Ϩ�g��3n��&�/GU�\��>C�'>_��f�q�O�I�3*��>�G�Xb��f� ���>C�'���Y�7�䝴�V�3��5n��&Zc+�\�7�d�r�٧�E�(�Lb�Yռ&�O�Q� ��|�O� �Iw�엓�9�b�I��Vs�$wάt���3��5�}��Qp�d����Le��^�=�}��>�t��f��ȹԚ�T��1T��$��>��Nr�̪�5�e�I�3���d��7�d��}�û��3�}⾊}&�>S<S�'�5vr�k��M�_�J����Le�I5��f���k��>�t�Y�>�u���3I��o�I��SM=S�'�P�>��'�#;��3+�g�D��>1Db�Y����T���>��>y�sy�O��(�o������Lb�YY}&׼��}&ռfU�\�Z��,b�Uռ��Қע�ת�g��T�Y�>1��}�OR�gQ�kU5���T�YT�Z�5y��g��M�~�*{�b�Y�>��gU��ﳔ}�>���,�y-e�E�Ϫt�ź�Қ�"�gU쳸�԰��}b�U�k�gy��*�g�d�%��*���2���}bh��g1�,00S�kU�X�Y7�d���J�Y\�Z��,b��f��R�g����=�}b���Y�h^�,�y-55/���J�Y�>K�>K�'�r�쳔}�Ϫt���n��&�e�>�u�u�O|{�>���X�y-��,�}Veu^��l�}��O�A����g��w�~���=p^n�}6�Ϯ�g��U��T�ڕ�y3�l��lb�]ռ6��֚�&�gW5��~�}�O�I��j^��>[�g��J�٬��}���)�]��f��7�dl�
v����>[�g+�dc�>���[�>�j^�:���}���&��o��cH�K��l�y�}6���Z���>��>u����+��~���'��)�j^��� �>��ym��l�}6�>��ym�ym�ym�}vu�ks�k�}v�u�\��7�dl�����ﳵ浕}bhU�k3�le�M�+��f�٪�le��]hx�ا���!�9��}���:�>9��:�>G��G�'+��a�9�u>t��T�s��s��u��u��=p^�}�J?U����#�}y�O�>��'�-�塚ש��f����!�9U��0��}��:�����}�	��S��a���9�C�ϩt��缎��Q�����}��>��Χb���sT�9�>�:�~�}��>���T��!��@�_����}�>�f��s*�9����<��f��O��=�u>��s�<�Q�ϡ���y�}��ϡS��:�u�\�њ�!���'L�'�E�;T�:�b�l�yI�s���a���}f4�~iU�ˈ}�Yri���J�1fӚ�������NbZ�2b��ǘ}�f����*���Dl�}���V��2>�n�>Fgܭ:�n�����)�D��}�����l���7��E\cMu#��*�1����}��>V����cZ�2e�C���>v�O6�~iU�ˈ}�Y����co�ɟH�5�n��OH~����5/�s^F~��Ǹ�e�>F��U?�c�>���)�D�}���T�1:�eU����c�>F����'��Ru#�Ǫ���d�%ռ��y��7}t��3�V��2>�e�>F缬�y�>�^g#��U��1���}�����3�"��U�q�}�bg��+�8�>^����ǵ���u��}�k^���T��J�q�}�f�����+�q�y��}�t��>κ��:ռ���8�}�f�l�5����7���}�t��>ο��z�݉}��:;�O<Rk^N��W��3���>y'��}����������8�>�5/W��Z�3���>N���8׼\��N~��y9���������8�>����>^��s�˕}��yyU�r�}\��I����|������x��8�}\�ǩ�����4T��+��}�~�^gW������6��j���'ǐ�緿�|>��V�i      f   C   x���� ��UL#�I/鿎���FS��Ƌ��X(4�݆L0��2�D߸�(l4�G��nR     