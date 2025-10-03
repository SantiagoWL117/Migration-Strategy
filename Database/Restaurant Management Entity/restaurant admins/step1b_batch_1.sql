-- Step 1b: V1 restaurant_admins Data (BLOB excluded)
-- Total records: 493

BEGIN;

TRUNCATE TABLE staging.v1_restaurant_admin_users;

INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    20, 0, 'James', 'Walker', 'james@menu.ca',
    '$2y$10$tZt0CtKpy9wdRqULpAF7C.r2On7zbBu5aKABYbGyWxKDzCW9tvIoO', '2025-07-17 13:10:09', 2125, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    22, 0, 'Linda', 'kuehni', 'linda@shared.com',
    '$2y$12$C0jMG84zZtb4H9Z9G/hgAuU8rzDSrP2qvmHfyWCsb7voTHWshMfwe', '2025-09-09 16:55:11', 1389, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    24, 0, 'Razvan', 'C', 'razvan@menu.ca',
    '$2y$10$JsPLI1WFXiAcO0lGNeBpweYGuCibYx4m8TRwOObUINpYjH.q9GmOS', '2025-06-06 18:24:00', 95, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    26, 0, 'stefan', 'dragos', 'stefan@menu.ca',
    '$2y$12$z0R/R0mT2onFI4BT6vypwODvnZ1jMYNkWYjniLeZhOL01DLUU6yR.', '2025-09-09 17:11:39', 1881, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    28, 96, 'Kal', 'Ghadie', 'kal.ghadie@sympatico.ca',
    '$2y$10$5DyrfVMh0uvYn7B9N.dGheJO/XUCnn.XPJmELMM4QjwZc1q7Eeehy', '2025-07-20 23:12:40', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    29, 101, 'Vinh', 'Trang', 'vinh613@gmail.com',
    '$2y$10$hdxXM5FfSYFDH4JEL4P9G.3.4XLGBEt8WWLfAaWW1/fNvErpzn182', '2022-07-13 13:41:08', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    36, 0, 'Darrell', 'Corcoran', 'darrell@menuottawa.com',
    '$2y$12$qQPIAs6KiGcaQr9kJhQSrO.rVbbOvc0OEaPaATiYJRkjJ28WVXDgK', '2025-09-11 13:21:48', 53, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    37, 0, 'Mathieu', 'Blake', 'mattmenuottawa@gmail.com',
    '$2y$10$1ABLtvX7YnALilrplhu1ZuqshE.zgeR0ncZY9COjWIvd5irEdJuDy', '2025-08-29 20:41:14', 16316, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    45, 0, 'Christos', 'Bouziotas', 'chris.bouziotas@menu.ca',
    '$2y$12$/.5vpHxyId66cLCq.00/5u8PEFWKj9DoUbAWpTtoSGxt5aDIUcWB.', '2025-09-12 00:26:23', 19565, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    47, 94, 'John', 'Ayoub', 'mamarosa375@gmail.com',
    '$2y$10$YjsdgKlsjmTSjLG0ibBrpO.bs1uV6yWRUSmEpCy8z5Ce1TV27XAwG', '2022-01-06 16:39:04', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    49, 120, 'Najib', 'Elhitti', 'Najihitti@hotmail.com',
    '$2y$10$A6vvUemBCxT5E/guqxasYOk8eLgWor5pn29Er/aShNzTKpZjn.pqO', '2013-04-30 15:49:59', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    50, 123, 'Charbel', 'Owner', 'Charb_k@hotmail.com',
    '$2y$10$HLQNUnH0nQORIYEgfVAbxe.FJzw28/mblN2URxcY1btmUun4.Qo5K', '2021-01-04 17:43:59', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    52, 124, 'Eli', 'eastview', 'jessicaelsalibie@hotmail.com',
    '559084efbcd42b9e37111e675589f47be05f9aa4', '2013-05-10 13:32:50', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    53, 130, 'Ziad', 'Bienpho', 'zrahbani@hotmail.com',
    '$2y$10$PC0PfwNNlnvYsSu01CsRLuMNhmStFpc.djS/Ho5poNDC0eBUlZyJG', '2025-07-18 18:36:50', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    56, 136, 'Winnie', 'Lemon Grass West', 'menu@lemongrassthaiottawa.ca',
    '$2y$10$4Srj2LWpuskO.8iv2YSi7udtz9Qx/AjIxeOBql.VW0JG0ftjD.vb2', '2019-10-17 16:20:42', 12, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    57, 137, 'Sam', 'Fung', 'menu@yangshengottawa.ca',
    '$2y$10$hboFhGlVIKSlNZ4KgpCjhej6HIOaQvkd4ebwEZcJ5B6zuPC/2Pue2', '2022-12-12 02:00:46', 15, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    58, 138, 'Anish', 'East India Co', '',
    'd2f75e8204fedf2eacd261e2461b2964e3bfd5be', '2013-05-17 13:43:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    64, 126, 'Pierre', 'vanier Grill', 'pierre_sfeir@hotmail.com',
    '5272bff6159a33425ae9339e6d6600b1474ec563', '2013-05-17 14:47:59', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    67, 152, 'David', 'Ogilvie Pizza', 'menu@pizzaogilvie.com',
    '3b4f3367054b005bf971f96026b4a55003189565', '2013-05-17 15:08:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    70, 117, 'Atif', 'House of Lasagna', 'ritaibrahim04@hotmail.com',
    '2025b385c47164d3c08cc34a40165efe9740d750', '2013-05-24 14:45:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    71, 155, 'ivan', 'greekos', 'ivan.masrieh@gmail.com',
    '$2y$10$CcfmLrhqbYDGG0RK3KYjWeYqcKy41x.AIMsH7np8bPmsa.gamcsR6', '2021-04-16 17:30:20', 9, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    72, 162, 'Gabi', 'House of Pizza Richmond', 'gabby@houseofpizza.ca',
    '$2y$10$nEVhZ96qnhIR/pU1aa.OPeM4kOE1X41eU3.ZShhD5psUfH73l1wYy', '2025-07-18 18:48:16', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    75, 150, 'Yussef', 'Zibara', 'menu@momschickenottawa.com',
    '83787f060a59493aefdcd4b2369990e7303e186e', '2013-05-24 16:02:31', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    78, 154, 'Owner', 'Wing Hing', 'menu@winghing.ca',
    '$2y$10$sgbyLAKf1FekbnrV7klqAeiNppu6kqMzicv52I7ANOwEci68wz4nm', '2022-02-11 01:21:53', 16, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    79, 146, 'Mike', 'Merivale Pizza and Wings', 'm_elserji@hotmail.com',
    '$2y$10$g0PQwBvEz7jYmtMvnxYYG.OIbRcahPE9G9OE7kdqb7Qel6lNt12ii', '2019-04-10 14:17:42', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    80, 164, 'Aboudi', 'Milano Innes', 'aboudi-z@hotmail.com',
    'fecd32bb290b8e0ab26556b1c6d0996d1491b9cb', '2013-05-31 14:38:03', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    82, 161, 'Robbie', 'Milano Merivale', 'jdita74@hotmail.com',
    '58b9c5c3810c363098cc055dc2a41e9d77d1f014', '2013-05-31 14:51:18', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    88, 114, 'razvan', 'razvan', 'razvan@menu.ca',
    '$2y$10$VwazRzMeDNniPzQD.zLnjOO.j/Nrp8q26r/1bxUVWfpQrfKUmqXtO', '2019-02-21 14:21:01', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    97, 179, 'Zhong', 'no 1 chinese food', 'menu@no1chinesefoodottawa.com',
    '83787f060a59493aefdcd4b2369990e7303e186e', '2013-06-27 18:14:48', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    100, 132, 'Robert', 'Mozza Pizza', 'menu@mozzapizzagatineau.com',
    '83787f060a59493aefdcd4b2369990e7303e186e', '2013-07-31 13:57:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    101, 183, 'Marwan', 'Aylmer BBQ', 'marwabitar1@gmail.com',
    '$2y$10$86cLIJFYblvZa1xViIiCmeEeEQ80Z91l0uy7sdsZf6zZrthiiKEmu', '2021-01-06 16:21:50', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    103, 175, 'Sam', 'Vanier Pizza', 'samir1boulos@hotmail.com',
    '6e1a438cfe5a6c9e2165665f8c2258849ccc43f0', '2013-07-31 14:41:13', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    104, 177, 'Ali', 'Fyed', 'funkyimran57@hotmail.com2',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2013-07-31 14:50:28', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    107, 187, 'Tony', 'Bo Xian Fang', 'tony74f@hotmail.com',
    '$2y$12$az2uU/7BqjIDb0mk5WzezeHe1M8DJhlnnLGNqRh81MYTlXtZwQZ.y', '2025-09-12 00:33:20', 1168, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    109, 200, 'Jason', 'Hajjar', 'georgiesoncarling@gmail.com',
    '$2y$10$ku.unVTLf0XRpnMk.VuCnOd.fHnKQ4PPZ2ui7SF9lJM6M90AybF8K', '2025-07-18 15:22:12', 62, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    119, 208, 'George', 'MIlano St Laurent', 'stlaurent.milanopizzeria.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2013-08-28 13:32:51', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    124, 109, 'Ahmed', 'Mouaj', 'saadcanada2019@gmail.com',
    '$2y$10$Zf/PuHJHgF9DNy.zb5Ll9OZe9wOCCD9r7CHdVCxI3uLBR4cOlbnUa', '2022-12-02 16:18:24', 16, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    126, 221, 'Subra', 'Golden India', 'subra_deb@hotmail.com',
    '8cb2237d0679ca88db6464eac60da96345513964', '2013-09-11 14:35:33', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    131, 224, 'Pen', 'Ginkgo Garden', 'menu@ginkgogarden.ca',
    '83787f060a59493aefdcd4b2369990e7303e186e', '2013-09-11 15:24:57', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    133, 198, 'Wei', 'Vu', 'weisnoodlehouse@gmail.com',
    '7c222fb2927d828af22f592134e8932480637c0d', '2013-09-11 15:40:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    135, 114, 'Chris', 'Bouziotas', 'chris@menu.ca',
    '$2y$10$8DkUsCQPfl4t4ktOPXiXP.HE0fY1K3fA9eFYikjRrZ7ld5JjrSnKm$2a$10$.vDbOGQcKXSoDioqECUO5.ppj8TXeYKKZo.y4nyWs9u110gWPsjN2', '2025-07-18 00:45:15', 29, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    136, 184, 'Rabih', '', 'Rabih2015_01@hotmail.com',
    '45cd07b4890187a7bcece8172b4da361b291d5fb', '2013-09-19 14:10:31', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    137, 231, 'Moe', 'Osman', '2osman_moudi@hotmail.com',
    '7e9d60c195de1dc309b2a882e42e307372b14740', '2013-09-19 14:24:14', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    139, 227, 'Elias', 'Al-Khoutsi', 'e.alkoutsi@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2013-09-19 14:50:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    140, 226, 'Mohamed', 'Younes', 'myounes@aimcanada.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2013-09-19 14:57:54', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    143, 229, 'Mazi', 'Pizza Mia', 'shawks32@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2013-09-19 15:37:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    144, 235, 'Rajesh', 'Mehta', 'chilliesindian@gmail.com',
    '$2y$10$nArTHRoev50l8zacVEyIaOZzvbbEelrbJ81uNgyzOCEx1vAc/PiQ6', '2021-11-27 17:02:28', 65, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    145, 237, 'Houseini', 'Fadel', 'houseinifadel@hotmail.com',
    '$2y$10$tWGR/oQiu0ek651MfRdlg.OXDT5Hp6guGfkmFLnQ6EpFiFJ0TTr1.', '2023-09-14 18:47:31', 55, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    146, 232, 'Dave', 'Situ', 'davesitu@me.com',
    '$2y$10$NsaPmo3ZpRR.aVsLCk2Fg.HISjTF4IoE6y2gO/.uUP0HOgOaPcKZa', '2020-10-07 14:28:31', 10, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    149, 0, 'Mazen', 'Kassis', 'corporate@milanopizza.ca',
    '$2y$12$aYc/vCpeWepDOfnkfem55OChmui9D9pjv.ccNEUHapg2oitkaocnq', '2025-09-12 00:27:27', 33176, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    150, 204, 'Mazzen', 'Tabaja', 'mazent.milano@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2013-10-15 19:49:13', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    151, 215, 'Moe', 'Ghandour', 'milano.cornwall@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2013-10-15 19:49:49', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    152, 245, 'Robert', 'Choueiri', 'sammaalouf1974@hotmail.com',
    '29062076f46fac2a0b924d9b932d4c7951d8963c', '2013-10-16 13:25:09', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    157, 244, 'Pierre', 'Greek Express', 'greekexpress@hotmail.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2013-10-21 21:44:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    161, 263, 'Najib', 'Elhitti', 'Najihitti@hotmail.com',
    '$2y$10$9hG5n.dQXrW2wbQqf30L9ubvmqwRWnt0Trt7N5WMnmiM9pi/IBLQ.', '2013-11-12 20:21:07', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    172, 199, 'George', 'Labaki', 'georges.labaki@hotmail.com',
    '$2y$10$AJKZ7vg2D7jqE0/tBqC5oOKMkndgit/BngtoUMv2E7rj4JU/0.M/y', '2013-11-28 15:11:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    173, 264, 'Jason', 'Farhat', 'crystal_geinoz@hotmail.com',
    'aef252b98ef216c079010015be0d96a96bc02aa4', '2013-11-28 21:12:33', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    174, 273, 'Sam', 'Ha', 'sam_hakw@yahoo.com',
    'e4d8c755684d09f212ca8ef859d61077c40328ba', '2013-11-28 21:17:15', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    178, 280, 'Thanh', 'Tran', 'menu@phodaubo.net',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2013-12-03 16:07:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    179, 265, 'Hai', 'Dang', 'phanthianhthu999@gmail.com',
    'cf8fb7c558dab77a3c522a23ba04499215dff2e7', '2013-12-03 16:09:36', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    185, 287, 'Nazrul', 'Rahman', 'linda52580@yahoo.com',
    '512dc16fe08403da47cc55efe17ef880511ea7dc', '2013-12-10 13:39:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    188, 234, 'Raed', 'Ibrahim', 'raed.ibrahim@hotmail.ca',
    'a80b0aaadca2db3f3b2038a0ab24e2d5b29e655e', '2013-12-10 18:39:27', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    189, 206, 'Ziad', 'Nasser', 'znasr@hotmail.com',
    '$2y$12$6kLQ4POTgs/TTITbsX46/.jcMmkauJGcTZA/rz4rK.Oa5pyrWFrQC', '2025-07-29 22:02:35', 29, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    194, 295, 'Micheal', 'Huang', 'water_333@hotmail.com',
    '90265328d7406570f0f8d13b159f0b8e4940c676', '2013-12-20 13:49:23', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    196, 275, 'Sam', 'Elsarji', 'menu@tonyspizza.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2013-12-30 16:06:48', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    197, 294, 'Wendy', 'Huang', 'hui3820@hotmail.com',
    '$2y$10$D9CUpH5.o/El.TvCot4XveFuh/gy8lDSroQzXKR7/28UZDY/gfX2G', '2025-07-14 23:36:33', 79, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    201, 308, 'Sam', 'Khoury', 'ottawaliquorservice@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-01-06 15:51:30', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    207, 291, 'Bassam', 'Naanoua', 'bassamnaanoua@hotmail.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-01-16 20:34:15', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    213, 91, 'Tony', 'Ho', 'tonyho13@sympatico.ca',
    '$2y$10$IehxIBbvRllGkn.NFdLCdOV9vO8kMqJXWMv/6/oz5j.jMoJ2xn9Km', '2014-01-21 21:10:01', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    214, 317, 'Nguyen Trei Thanh', 'Thuy', 'menu@phoorchid.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-01-22 15:09:51', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    219, 324, 'Ozair', 'Akbari', 'akbariozair@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-01-27 19:01:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    220, 328, 'Moe', 'Toufaely', 'mtoufaely@gmail.com',
    'b3346e3301baca4230690432925d026d75a8f2e8', '2014-01-27 20:38:18', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    221, 327, 'Cui', 'Zhou', 'lailaichinesefood@gmail.com',
    '$2y$10$L26I0rtB6DK8S2fTFseoAe5jYtmU0ml2tR/7r6s9EdwJYnp.bHOj2', '2019-06-04 23:38:25', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    223, 325, 'Drago', 'Vreco', 'dvreco@yahoo.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-02-06 21:42:52', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    224, 318, 'Parmjit', 'Korl', 'indianpunjabiclayoven@gmail.com',
    '$2y$10$r9P7FHMyB8xEfAZkqcRt1OOl9dfNbavL/Z9xkdDUbC6hdHF.rgiEm', '2025-06-27 01:59:09', 6, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    228, 334, 'Jean', 'Assaly', 'jean_assaly@live.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-02-12 20:37:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    230, 335, 'Rupinder', 'Pal', 'rupinder.pal@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-02-14 19:01:44', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    231, 337, 'Allan', 'Nguyen', 'allannguyen79@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-02-14 19:23:47', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    236, 344, 'Eli', 'El-Salibi', 'menu@montliban.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-02-27 14:57:31', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    237, 340, 'Habib', 'Hashemi', 'cheezypizza@hotmail.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-02-28 16:08:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    243, 344, 'Eli', 'Al-Sabibie', 'jessicaelsalibie@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-03-10 19:45:59', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    247, 362, 'Amir', 'Ottawa Pizza', 'pizzapie241@rogers.com',
    '$2y$10$6ic0Zbod7MxnGPVw7TgjG.eepi9L0QUNgKdtoRriHY9UdmrrelDF.', '2020-01-13 05:39:28', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    249, 365, 'Mohammad', 'Hosossain', 'rifathh@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-03-17 15:54:22', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    253, 364, 'Artan', 'Dalipaj', 'rozadalipaj@yahoo.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-03-18 18:04:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    255, 367, 'Hussein', 'Lahmar', 'husseinelahmar@gmail.com',
    '60ac0291534511d5626f759b0f84676b01d74104', '2014-03-24 20:31:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    261, 374, 'Musa', 'Reza', 'rezamusa18@gmail.com',
    '$2y$10$Es5MISzxNZ/aHMugD5U14OWnOI6eDRHRERxPT6mmYVx/kHDG88mt6', '2014-03-28 16:10:15', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    264, 384, 'Chadi', 'Hage', 'chadi_hage10@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-04 13:19:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    267, 381, 'Patrick', 'Shorros', 'pshorros@yahoo.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-04 14:31:51', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    275, 388, 'Esmail', 'Sharifi', 'ish_sharifi1981@hotmail.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-08 17:33:23', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    277, 387, 'Jay', 'Tran', 'orchid_sushi@yahoo.ca',
    '$2y$12$Xrnd7Xmm.O1QPVg.EWCqu.FOv2Xn8/STN2PEXBvaUGBTLbaDko.re', '2025-09-01 21:26:41', 3580, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    278, 114, 'fname', 'lname', 'dfstefan@gmail.com',
    '$2y$12$cw6qTwE2QZR48Z/jZ/UEP.7FH9fp2.R5HXJNhBlmbN.3nx7qo4ZGG', '2019-03-28 08:30:21', 0, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    279, 378, 'George', 'Ibrahim', 'georgeibrahim500@yahoo.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-10 19:32:55', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    286, 403, 'Richard', 'Yiu', 'little_devils_17@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-21 14:37:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    288, 394, 'Sanjay', 'Sanjay', 'menu@larumeur.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-21 14:51:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    290, 395, 'Sanjay', 'Sanjay', 'menu@lepalais.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-04-21 15:08:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    292, 406, 'Kim', 'Huong', 'laura_paniagua513@hotmail.com',
    '$2y$10$bRWs7TjEzVcxWDZyd8VfSOXElHrBwqcA1CUzEUhFVvg1WVjbsLZQy1', '2024-10-08 02:13:12', 40, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    295, 413, 'XiuJuan ', ' Qiu', 'elita0303@yahoo.com',
    '82a2bbfd47c5bfbe6b0a05976e4dc99bceed8c76', '2014-04-21 16:52:54', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    300, 419, 'Handel', 'Sous Le Palmier', 'info@souslepalmier.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-04-22 15:31:03', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    306, 376, 'Raymond', 'Tin', 'bangkokthai.garden@gmail.com',
    '$2y$10$ftIE1eLW1rDm6jq5EEE0zewmNKJQfo1zlGMqueUDdG8a0tmZO6iEC', '2024-10-01 12:04:08', 68, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    313, 409, 'Ademh', 'Pure Joy', 'ademh1129@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-02 13:33:18', 0, '0', 'n',
    NULL, NULL
);