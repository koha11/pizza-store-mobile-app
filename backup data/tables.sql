-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.app_user (
  user_id text NOT NULL,
  user_email text,
  user_name text NOT NULL,
  phone_number character varying NOT NULL,
  user_avatar text,
  role_id text NOT NULL,
  is_active boolean DEFAULT false,
  CONSTRAINT app_user_pkey PRIMARY KEY (user_id),
  CONSTRAINT app_user_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(role_id)
);
CREATE TABLE public.category (
  category_id text NOT NULL,
  category_name text NOT NULL,
  category_image text,
  CONSTRAINT category_pkey PRIMARY KEY (category_id)
);
CREATE TABLE public.customer_order (
  order_id text NOT NULL,
  customer_id text NOT NULL,
  manager_id text,
  shipper_id text,
  order_time timestamp without time zone,
  accept_time timestamp without time zone,
  delivery_time timestamp without time zone,
  finish_time timestamp without time zone,
  status text NOT NULL,
  payment_method boolean DEFAULT false,
  total_amount numeric,
  shipping_fee numeric,
  note text,
  shipping_address text,
  CONSTRAINT customer_order_pkey PRIMARY KEY (order_id),
  CONSTRAINT customer_order_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.app_user(user_id),
  CONSTRAINT customer_order_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(user_id),
  CONSTRAINT customer_order_shipper_id_fkey FOREIGN KEY (shipper_id) REFERENCES public.app_user(user_id)
);
CREATE TABLE public.item (
  item_id text NOT NULL,
  item_name text NOT NULL,
  item_image text,
  description text,
  price numeric NOT NULL,
  category_id text NOT NULL,
  CONSTRAINT item_pkey PRIMARY KEY (item_id),
  CONSTRAINT item_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id)
);
CREATE TABLE public.item_variant (
  variant_id text NOT NULL,
  category_id text NOT NULL,
  CONSTRAINT item_variant_pkey PRIMARY KEY (variant_id, category_id),
  CONSTRAINT item_variant_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id),
  CONSTRAINT item_variant_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.variant(variant_id)
);
CREATE TABLE public.order_detail (
  order_id text NOT NULL,
  item_id text NOT NULL,
  amount integer NOT NULL,
  note text,
  actual_price numeric NOT NULL,
  CONSTRAINT order_detail_pkey PRIMARY KEY (order_id, item_id),
  CONSTRAINT order_detail_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.customer_order(order_id),
  CONSTRAINT order_detail_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id)
);
CREATE TABLE public.order_variant (
  variant_id text NOT NULL,
  order_id text NOT NULL,
  item_id character varying NOT NULL,
  CONSTRAINT order_variant_pkey PRIMARY KEY (variant_id, order_id, item_id),
  CONSTRAINT order_variant_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.variant(variant_id),
  CONSTRAINT order_variant_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id),
  CONSTRAINT order_variant_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.customer_order(order_id)
);
CREATE TABLE public.role (
  role_id text NOT NULL,
  role_name text NOT NULL,
  CONSTRAINT role_pkey PRIMARY KEY (role_id)
);
CREATE TABLE public.user_address (
  user_id text NOT NULL,
  address text NOT NULL,
  address_nickname text,
  CONSTRAINT user_address_pkey PRIMARY KEY (user_id, address),
  CONSTRAINT user_address_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(user_id)
);
CREATE TABLE public.variant (
  variant_id text NOT NULL,
  variant_type_id text NOT NULL,
  variant_name text NOT NULL,
  price_change numeric NOT NULL,
  CONSTRAINT variant_pkey PRIMARY KEY (variant_id),
  CONSTRAINT variant_variant_type_id_fkey FOREIGN KEY (variant_type_id) REFERENCES public.variant_type(variant_type_id)
);
CREATE TABLE public.variant_type (
  variant_type_id text NOT NULL,
  variant_type_name text NOT NULL,
  is_required boolean,
  CONSTRAINT variant_type_pkey PRIMARY KEY (variant_type_id)
);