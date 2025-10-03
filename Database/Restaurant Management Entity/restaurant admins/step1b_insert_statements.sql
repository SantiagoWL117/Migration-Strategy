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
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    314, 435, 'Honsat', 'Restaurant Mysore', 'menu@restaurantmysore.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-02 14:28:23', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    320, 434, 'Ali', 'Ali', 'moe.srour69@gmail.com',
    'ffa769562da75d344801d37dbb6dcd44c7a9c4a8', '2014-05-12 15:49:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    324, 425, 'Eli ', 'Maalouf', 'eliasmk07@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-13 13:53:09', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    326, 416, 'Ralph', 'Tannis', 'rgt@fatalberts.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-13 14:08:12', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    329, 456, 'Ahmed', 'Choudhoury', 'info@gateofindiamontreal.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-13 14:34:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    331, 429, 'Hai', 'Au Lam', 'menu@oceansushi.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-21 15:18:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    334, 438, 'Karim', 'India Cafe', 'a.karim@hotmail.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-22 18:38:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    335, 441, 'Azar', 'Tahir', 'azatahir@1for1pizza.com',
    '$2y$10$rUTQJD3F/KN8xlY7F/YAHejFnwIvRtUxvRggZNRpRZN.Oc169xDu2', '2025-03-10 17:13:11', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    348, 458, 'Louie', 'Classico Louie\'s', 'l.carvalho@bell.net',
    '11bbbcfd4cbaab57645d2aae47f1a2c38779d8de', '2014-05-28 20:55:12', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    350, 451, 'Moe', '', 'moe@live.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-30 16:16:48', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    351, 483, 'Nadir', 'Jiwani', 'nadirjiwani@yahoo.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-05-30 16:18:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    356, 457, 'Wai', 'Yin', 'tontonyton@yahoo.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-06-09 19:00:26', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    363, 489, 'Raymond ', 'Aouad', 'jnray3377@gmail.com',
    '$2y$10$ct0VR9osCITJB/rT6BUuBOQJAkkohXZ75D/vbuw/VeAfCxHPX6UDm', '2022-05-03 13:03:29', 8, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    367, 502, 'Tony', 'Tong', 'cafesaffron195@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-06-16 13:04:39', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    381, 511, 'Shen', 'Yichao', 'L542245869@gmail.com',
    '$2y$10$mbS1JnycaIr9xdq0rNZlFevj92839hNYAzwRe1/m1vP/qvN5n9AC6', '2020-01-22 04:05:03', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    383, 507, 'Michael', 'Poissant', 'carolinascuisina@gmail.com',
    '3b05b91bf36c2dc503878a97c5a79976ed6e2554', '2014-07-29 17:02:13', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    388, 513, 'Ali', 'Mahmoud', 'alimokwar@gmail.com',
    '$2y$10$syi5iMldUYLWKkPa3KBn6eiedT3f09xYSaVCxt6n80vtkPicy5QkG', '2014-08-18 19:21:09', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    399, 542, 'Lam', 'Pham', 'sachisushi@yahoo.com',
    '$2y$10$vF0qtqsVEgp5du42udtUIO9etGScnftZtZ/i2HLB86WBs7m7u0M96', '2025-04-14 16:26:53', 41, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    406, 549, 'Adam', 'Sadik', 'bkstravel1@live.ca',
    '$2y$10$VIaml2vSFr5i/6.DABoAjO0Hr8lqwpgtn96HRx4QMtM5ij5Fcyxga', '2021-10-24 06:46:57', 30, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    407, 547, 'Nemi', 'Cheikh', 'yorgosgreekfood@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-09-22 15:19:07', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    413, 550, 'Jian Huan', 'Jing', 'johnjiang14@outlook.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-10-01 17:35:26', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    417, 553, 'Safdar', 'Shokomand', 'safdar.s@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-10-06 20:17:03', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    420, 527, 'Amir-re', 'Zaian', 'amirtorbat@yahoo.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-10-08 13:37:34', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    425, 523, 'Miyuki', 'Sushi Bar', 'miyukisushibar@hotmail.com',
    '$2y$10$esQeeYpnLyXEs8Cp23QPp.Mc.LCsRItmVGzdTD42CU/qJtzJMFKUa', '2022-07-19 20:01:35', 47, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    432, 541, 'Johnny ', 'Kong', 'johnnykong007@gmail.com',
    '76708c74550a6fc53363e0a502bdad45316784d3', '2014-10-23 13:47:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    436, 572, 'Fares', 'Hassan', 'king_fares_619@hotmail.com',
    'dfe8c2120a076093ebfad87e1ed9f6420662331b', '2014-10-24 14:41:20', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    441, 593, 'Ha ', 'Bao', 'saigonpho232bank@yahoo.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-11-11 21:36:08', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    443, 617, 'Kaseem', 'Cheantani', 'kcheatani@sympatico.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-11-12 21:06:44', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    446, 624, 'Timorshah', 'Akbari', 'akbaritsa@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-11-13 14:26:32', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    447, 624, 'Timorshah', 'Akbari', 'akbaritsa@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-11-13 15:11:25', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    455, 572, 'Fares', 'Hassan', 'king_fares_619@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-11-13 20:28:33', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    459, 585, 'Jewel ', 'Uddin', ' jewel.uddin514@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-11-13 21:19:51', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    468, 649, 'Jabe', 'Abeeat', 'jaber.abeeat@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-11-26 18:37:29', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    470, 650, 'Kaseem', 'Cheantani', 'kcheatani@sympatico.ca',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-11-26 18:47:57', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    471, 433, 'Mohammed', 'Srour', 'moe.srour@hotmail.com',
    'ffa769562da75d344801d37dbb6dcd44c7a9c4a8', '2014-11-28 20:05:44', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    474, 607, 'Jacob', '', 'Jacobhaydar1@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2014-12-02 18:26:05', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    482, 597, 'Raja', 'Khalil', 'info@butterchickenhut.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-12-05 16:25:30', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    486, 645, 'Stephane ', 'Cote', 'admin@asianstarsrestaurant.com',
    '1729a45c0e35e98c0894812118f945e1bf18f0cd', '2014-12-09 20:24:21', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    493, 660, 'Yan', 'Hoa', 'yan_hoa@yahoo.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2014-12-16 19:14:16', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    494, 635, 'PJ', 'PJ', 'thepizzajunction@outlook.com',
    '3491ec5996d193ca181a31f864f898cfb6a6be42', '2014-12-17 21:41:09', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    495, 662, 'Phuong Hai ', 'Hoang', 'trung3636@rogers.com',
    '7681605494aadad2ac65f0c2e90fd4bc2e8d4368', '2014-12-22 14:42:01', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    506, 455, 'Porte', 'De L\'Inde', 'mohsinchw123@hotmail.com',
    '8ecfe232299dbd5e3db57ed117f78f0dccbe2841', '2015-01-30 21:44:41', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    509, 666, 'Greg ', 'Sim', 'fearlessleader@tonimoes.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2015-02-10 18:27:05', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    510, 669, 'Thai ', 'Nguyen', 'thainguyen3142@gmail.com',
    '$2y$10$8YfzoYfMWK2WbI52wFzV0evuWVyLbgMYaSfLHi2iOb4I8z7d8QcKO', '2015-02-12 17:48:16', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    514, 672, 'Ken', 'Chow Hum', 'kenchowhum@hotmail.com',
    '$2y$10$XAgoRFpYsvW81Lzg5g/jeOld6OqTtnCDKpfiucbXt3kIGnJ.K13he', '2020-08-26 01:48:16', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    515, 670, 'Thilee', 'Ram', 'thilee.ram@gmail.com',
    'e7f931ac853942e755f06a266b00b8b166103b0d', '2015-02-19 21:47:34', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    519, 683, 'Rabih', '', 'Rabih2015_01@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2015-03-02 20:25:16', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    523, 686, 'Sean', 'Lynch', 'seanandnid@gmail.com',
    '$2y$10$5/zqkhdUZDj/r/v6MUxiAu7rDEm1AewKSSRVFC.PbN6jCRXSceBqy', '2025-04-22 15:14:42', 4146, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    528, 695, 'Alok', 'Deb', 'Barnali.deb@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2015-04-02 18:51:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    534, 234, 'Kayla', 'La Spezia', 'moi_kayla@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2015-04-22 14:37:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    535, 699, 'Ravinder', 'Tumber', 'hostindia_ottawa@yahoo.ca',
    '$2y$10$QpkLAWdyf9yuUen2VCg0JOwQ1w5l3Y1AJFx29YJGnFkJduwXrh77i', '2021-03-21 04:10:17', 19, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    542, 708, 'Allan', 'Pho Bo Ga King', 'allannguyen79@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2015-05-20 16:03:27', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    543, 701, 'Charanjit ', 'Singh', 'charanjit65@hotmail.com',
    '$2y$12$tLdCYAXJpBfHusBFm3azAu5k4TKj2D2HVac/zx1cfUE6ObfPl4jn6', '2025-09-11 23:30:26', 5431, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    545, 692, 'Ali', 'Fyed', 'funkyimran57@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2015-06-04 16:36:13', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    547, 707, 'Xin', 'Kuang Tam', 'jtam048@uottawa.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2015-06-08 19:07:36', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    549, 711, 'Jess', ' ', 'thebeermandelivers@gmail.com ',
    '$2y$10$ujWHWLvMZLxbDTTt0nv8G.bf6hw/nn7N64Ysxc4gQ8Hs6u3sRBGGu', '2022-05-05 01:38:50', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    551, 703, 'Hichah', 'Hachlaf', 'hima.ca@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2015-07-13 16:54:47', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    553, 441, 'Aras', 'Tahir', 'arastahir@1for1pizza.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2015-07-22 15:46:51', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    557, 715, 'Ethan', 'Fusion House', 'yurongtcp@gmail.com',
    '$2y$10$.8XPK8QtY1WFu.pC/HRycONpE4ZKegkSXwjmZOGumqJ4fHVl.EqyK', '2021-11-25 17:14:13', 27, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    560, 712, 'SarWar ', 'Hazara', 'sarwarhazara@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2015-08-28 17:49:22', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    561, 0, 'George', 'Nicolae', 'george@menu.ca',
    '$2y$10$KehV948k8.8NmdDfCwgJSOvyVq4bVRh1oJqgq3v4Mrq7CIo8dSfU2', '2025-08-06 18:43:31', 925, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    564, 732, 'Oruc ( Alex )', 'Dereli', 'sabrigul@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2015-10-21 14:07:13', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    565, 727, 'Chuong ', 'Nguyen', 'camvan73@gmail.com',
    '8fffb7eb63008e7fddd449524f4371b4ee6117f2', '2015-11-03 17:37:31', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    567, 448, 'Merza', 'Zarabi', 'masihzarabi@hotmail.com',
    'f7c3bc1d808e04732adf679965ccc34ca7ae3441', '2015-11-09 17:46:52', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    569, 137, 'Sam', 'Yang Sheng', 'masfung@rogers.com',
    '$2y$10$jXlDBJfT1utCdixWHwlLt.IHeHMrWdCIADAToT.GfbgFxNjnr1HYO', '2019-04-12 19:20:36', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    575, 735, 'Wakil', 'Zazay', 'wzazay@hotmail.com',
    '8acff40bdcd10ea8a41883d4838b40adf57ccbbf', '2015-11-24 19:59:48', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    577, 736, 'Yussef', 'Ahmad', 'shawarmahouse2@hotmail.ca',
    'a19549e4bed474b8091839e4bcccae0efa73320a', '2015-11-24 20:14:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    578, 739, 'Musharraf ', 'MIah', 'eatatmias@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-01-05 18:37:46', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    580, 750, 'Vincent ', 'Gobuyan', 'Vincent.gobuyan@gmail.com',
    '6538701b03e68f50b9ec12c99d92e3e5b7d3584e', '2016-01-20 21:00:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    581, 753, 'Alwin', 'Gao', 'huangao175@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-01-21 19:54:14', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    592, 452, 'Ahmed', 'Meliji', 'Edm@fatalberts.ca',
    '4146dcefe280fdb0c0a14230fab491d10f9ec3b1', '2016-03-15 15:28:43', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    593, 452, 'Ahmed', 'Melijio', 'edm@fatalberts.ca.',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-03-15 16:30:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    596, 774, 'Jorge ', 'Bahamonde', 'jbahamonde26@videotron.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-03-16 19:59:49', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    597, 0, 'Alexandra', 'Nicole', 'alexandra@menu.ca',
    '$2y$10$jPKgGBwuA5ub7YqopyxHw.fpAcVt2Ihtd705ERBdewdio289Rovfe', '2025-09-08 17:14:27', 1112, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    601, 780, 'Jack ', 'Khalife', 'khalifejack@gmail.com',
    '$2y$10$Kq1LBks.GK8pilLlmCHmbe8PCotZoAncSJelzcSojlRj8UEdIaTma', '2020-04-07 13:36:12', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    602, 781, 'Rupinder', ' Pal', 'aaharaltavista',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-04-07 17:22:18', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    603, 350, 'Azad ', 'Germavy', 'vincent.chabot@revenuquebec.ca',
    'a9c430ff803d76a8f367ac76b129965e0d0ab754', '2016-04-07 18:53:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    604, 782, 'Elie ', 'Malo', 'pizzadhp@hotmail.com',
    'c54fdfef90105d0a90069ac719ec26f1bc4991ac', '2016-04-14 16:21:08', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    605, 789, 'Krishna ', 'Ahir', 'krishnavaru8989@gmail.com',
    '$2y$10$FzkbaWbpvjOk2pVKdZ7eC.8QU18SUtkO2Q2b7GQ73eJzNbzlJ3Q42', '2025-07-04 00:52:27', 3, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    610, 793, 'Jade ', 'Racicot', 'accounting@goldenfries.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-05-27 17:19:01', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    613, 790, 'Marwan ', 'Chwah', 'marwanchwah@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-05-27 17:53:30', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    614, 790, 'Marwan', 'PIzza 9', 'pizza9canada@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2016-05-31 17:49:24', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    621, 758, 'Moe ', 'Osman', 'osman_moudi1@hotmail.com',
    '36c37f42bbe22e32182df2d8cefb9d7a11b874c1', '2016-08-04 16:24:53', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    623, 809, 'Bandar', 'Bandar', '2bandar74@hotmail.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-08-11 12:50:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    629, 804, 'Jihad ', 'Mohsen', 'jmohsen@jikatel.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-08-26 18:02:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    630, 757, 'Jaber', 'Abeeat', 'jaber.abeeat1@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-08-29 13:46:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    631, 791, 'Hedi ', 'Ali', 'hedii_70@yahoo.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-09-01 14:21:20', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    632, 821, 'Yussef', 'ROmaizan', '8215557mainstreet@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2016-09-20 20:10:32', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    633, 819, 'Steve ', 'Nasrallah', 'stevenez69@icloud.com',
    '6941144370f3c2d510df3aff7889b1aea3bb3628', '2016-10-06 15:02:33', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    634, 820, 'Anne ', 'Fernando', 'fernandanne@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-10-06 15:29:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    635, 822, 'Jessica', 'Liu', 'jessicaliu85@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-10-07 15:25:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    636, 717, 'Asaad', 'Alfares', 'asaadalfares@1for1pizza.com',
    '$2y$10$0DKa0xsz8OoF4PjrFGJxJe6ajACUFd.8Tq6Dyzxears5wroC/z1w2', '2016-10-10 22:48:03', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    637, 95, 'Darrell ', 'Corcoran', 'Darrell@menu.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2016-10-12 15:32:53', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    639, 824, 'Mohammed', 'Alhasen', 'milano-st@hotmail.com',
    '$2y$10$JW5O/0j4re7Nf2MIeUjKb.GxPcYoghtJvCz/vuhodT8x0FH5qktZm', '2016-10-25 15:36:37', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    641, 815, 'Shirlee', 'French', 'donna@ledgerlady.ca',
    '$2y$10$ljMV7VAVZDIIa6VM/mSRGeY1JQyWeYHPeCxRgS3FSxsihTJxQKHa.', '2019-03-27 20:00:27', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    642, 615, 'Paula', 'Hensley', 'paulajean029@gmail.com',
    '$2y$10$.i2DrNoIhxuzQu5pw0dF5ujyypgdbtT2ehogsnlpPFv8mXIglvBFK', '2019-01-01 17:34:20', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    643, 0, 'Talal', 'Almezel', 'talal.almezel@hotmail.com',
    '8270eb040eb7b3a6bda37b24d565d1f185b67b3d', '2016-11-26 21:49:33', 13, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    650, 766, 'Craig', 'Simplicity', 'craig@possimplicity.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2017-01-17 18:29:15', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    655, 245, 'Nada ', 'Lteif', 'nlteif@bellnet.ca',
    'a2c3533a590639268c44368b3a5cb3fab4050a31', '2017-03-02 16:20:18', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    657, 519, 'Rui ', 'Bin', 'angel3417@hotmail.com',
    '0a6cae75f86ab5cd27882e1b1e09afabe8edbcfa', '2017-03-06 20:56:27', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    658, 795, 'Bassam ', 'Farchoukh', 'bassam200@hotmail.com',
    '5e07e3a09df9cfee0ca0cc71c142cf5511535601', '2017-03-16 00:02:09', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    661, 541, 'Jiayu', 'Liang', 'yucarriecl@gmail.com',
    '70a8526f1f97ff0b27121a0384596811b9f3299c', '2017-04-12 17:47:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    662, 735, 'Wakil ', 'Zazay', 'bilalskabab@gmail.com',
    '6f845c08dc5d546d5d8c4f514ef8c1459911b9a7', '2017-05-01 15:47:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    663, 211, 'Talal', 'Almezel', 'talal.almezel@hotmail.com',
    '$2y$10$6Zq5SQnfGy8YEKGhF8bEFu7KiTkki2lhac0AyUJGOjgrDIgfAX3Sa', '2022-04-14 19:49:50', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    664, 190, 'Taha ', 'Ibrahim', 'milanopizza2430bank@gmail.com',
    '$2y$12$wAEAAXMx9M.VFQRFHvLTOODzSjLvN3C..vDnEg0dkKnflkeem8Hf6', '2025-09-11 22:25:11', 3012, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    666, 841, 'Manny ', 'Zamani', 'bigbonebbqkanata@gmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2017-05-10 16:05:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    668, 855, 'Ziad', 'Kassis', 'info@jojospizza.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-05-26 18:03:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    669, 852, 'Ziad', 'Kassis', 'info1@jojospizza.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-05-26 18:04:22', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    670, 853, 'Ziad', 'Kassis', 'info2@jojospizza.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-05-26 18:05:24', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    671, 473, 'Arun', '?', 'arun2920@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-05-31 20:19:24', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    672, 579, 'Mark', 'Roland', 'Roland.mark24@gmail.com',
    '21abb3cb85d44309b7b4005d8dc996862e012e27', '2017-06-01 14:02:22', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    673, 473, 'Mohammad', 'Fawad', 'fawad_mohammad@hotmail.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-06-01 18:02:46', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    674, 863, 'Joe', 'Ward', 'joesfamilypizzeria@live.ca',
    '$2y$12$crFbVfT2euiqV2dtoi57nOQH3bMIoPa2psnBVIdNARjryIPy57iPq', '2025-09-12 04:59:17', 42, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    675, 637, 'Peter ', ' Mariankos', 'rpurcell@on.aibn.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-06-06 16:53:20', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    676, 851, 'Abdul ', 'Azim', 'Mybackground1980@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-06-29 16:13:19', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    679, 865, 'Ali', 'Al-Shammari', 'almotayam20@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-07-04 14:49:22', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    681, 856, 'Ling', 'Tom', 'asiagardenottawa@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-07-04 16:25:30', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    683, 843, 'Grace ', 'Assouma', 'graceabide@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-07-04 16:31:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    685, 849, 'Ahmed', 'Yahia', 'andy_yahia@hotmail.com',
    '$2y$10$MBUvdLE38nGqVS7xwPFsMOwpvZeL1QDO1fklzNAoAojEERnxmbv4q', '2022-04-11 02:33:01', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    686, 836, 'Kin ', 'Tran', 'angrydragonzottawa@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-07-11 15:24:34', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    688, 519, 'Li', ' Yu Xiang ', 'yuxiangli.cga.cpa@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-07-27 15:33:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    690, 184, 'Mélodie ', 'Lalande-Bertrand', 'melodie.lalande-bertrand@revenuquebec.ca',
    '5f620e79f6f28a7b820a82d585df366d4184f596', '2017-08-08 17:23:53', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    691, 683, 'Mélodie ', 'Lalande-Bertrand', 'melodie.lalande-bertrand2@revenuquebec.ca',
    'fce7cae41c5ec654b4d8e6175a0ea61e19c7d0f5', '2017-08-08 17:25:52', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    692, 189, 'Shakila', ' Ahmadi', 'moesfamouspizza04@gmail.com',
    'a3db80cc6fe30470fe59dcd475a12fe18dcc8c21', '2017-08-09 20:43:25', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    694, 868, 'Mohamed', 'Alam', 'alamecobridge@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-08-23 15:10:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    695, 416, 'Kanishka ', 'Wahedi ', 'kanishkaw@fatalbertsralphs.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-09-01 15:12:16', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    696, 869, 'Daniel', 'Tan', '416100842@qq.com',
    '$2y$10$7XTE9QIo/A11NLFuamgm1ucJgBHqp7fCBqoLrmDH.7C1TLCc3dRKK', '2025-08-04 15:57:17', 0, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    698, 872, 'Haykel ', 'Zaidi', 'mozzapizza@live.ca',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-09-14 15:17:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    700, 0, 'Call Center', 'Menu Ottawa', 'menuottawa@gmail.com',
    '1d37fc1221e15c9eb09fe81d00dade3da7cbcf54', '2017-09-22 16:18:38', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    701, 0, 'matt', 'callcenter', 'callcenter@menu.ca',
    '$2y$10$wspf.9.sNYo7nBdN8.Kf3.acrM9U8AN1JCg6LwksSIjBERbyuBOg6', '2021-02-20 16:32:43', 19, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    702, 0, 'alexandra', 'callcenter', 'alexandra_cc@menu.ca',
    '$2y$10$H65U9/B14KTcNDB9GY5vC.j9OuF488/Yetci8a5dzYx5qo0KzVm4O', '2025-06-30 19:35:48', 1, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    705, 89, 'Rola ', 'Haddad', 'rolahaddad66@gmail.com',
    'd14b3591ef4c5c8020e183b3ba445a225b1e9959', '2017-10-10 14:26:19', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    709, 876, 'Trung ', 'Vo', 'trungvo120@gmail.com',
    '7a658482bdbe4b81985aa8289c0f3b0d1dd2f0d4', '2017-10-17 17:40:14', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    712, 808, 'Jacob', 'Haydar', 'Jacobhaydar@hotmail.com',
    '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '2017-10-23 17:41:16', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    713, 879, 'Bandar', 'Abdalla', 'bandarabdallah@gmail.com',
    '$2y$10$ntFa4KD0KI/C8YZafGN.SuQu1bf2wf5qtV4KsaJ9h72GBFVwdcIiW', '2017-11-01 19:14:54', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    714, 878, 'Aniket ', 'Patel', 'patelss@outlook.com',
    'b7928c823eea5426669366eddad453d00d27781e', '2017-11-08 20:37:38', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    715, 878, 'ANiket ', 'Patel ', 'patelss@outlook.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-11-15 21:02:46', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    716, 785, 'Khaled ', 'Al-Nabhan', 'kalalnab7@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2017-11-17 19:13:52', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    721, 880, 'Andre ', 'Eid', 'eidandre@hotmail.com',
    '$2y$12$usLG/sy.W10QhQA6OBVPueqaCuDoj.O0gDdtvk6qex2tjWUCCv8e1y', '2025-08-03 15:10:05', 6, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    722, 109, 'Micheline ', 'Wakim', 'micha@deltaxaccounting.com',
    '6d3a5089f4c499de42b95ee11ed280c96efbac8b', '2017-12-28 16:27:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    723, 254, 'Tawfik Said ', 'Hawjin', 'hawjins84@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-01-02 17:13:26', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    724, 651, 'Vanly', 'Keov', 'v_keov@yahoo.ca',
    '$2y$10$CIYiZJ.PPVjtodagf9vLW.k5jmMH3w41jpLKbXqp1UxcE9PW1Q0cu', '2020-10-09 16:57:21', 6, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    725, 874, 'Vanly ', 'Keov', 'johnnyv@sentex.ca',
    '$2y$10$XoIOQGKn76pTi.vgRTmnX.MemuRpxADxAHlFTK.bX09YbK.z9Jsym', '2025-07-19 20:37:40', 25, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    728, 885, 'Nathalie ', 'Shinh', 'Nshienh@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-01-09 17:14:55', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    730, 888, 'Tony ', 'Saikaly', 'tony10452@hotmail.com',
    'e79ef3b57e6e20f5e353a8fa850b30768b9322fb', '2018-01-26 20:11:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    731, 887, 'Ha', 'Nguyen', 'ha1@kanatanoodlehouse.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-01-29 17:56:53', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    732, 219, 'Cristina', 'Hong Fong Zhu', 'lemongrasselgin@gmail.com',
    '$2y$10$OkwS70yFCB05YU7t4jqLBuxQKsXcNPD6wNiXnTuY2dVjbSQtetx4O', '2025-04-07 17:14:34', 21, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    733, 506, 'Barsha', 'Deb', 'barshadeb7@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-02-08 20:13:41', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    735, 802, 'Fadi', 'Issa', 'fido_issa@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-03-06 15:17:21', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    736, 886, 'Andrew', 'Lay', 'andrew@sulawok.com',
    'b23fe2e90bdd002de6c7bfb254738da7f1c71d33', '2018-03-09 13:50:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    738, 207, 'Essin', 'Hazara', 'ehazara@hotmail.com',
    '$2y$10$4qnBzHuJl1axIR7oqEM3ueTsrTY3eJ62ULhf7qOPw4tMEU/2EVlzK', '2025-05-27 07:43:46', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    739, 892, 'Qing', 'qi', 'ilyqq@hotmail.com',
    '$2y$10$.by0NG3obci197ESGbwTPOqaSQ4k182ZnziLxto/dzOHvhoMQ1wUO', '2020-07-01 00:41:11', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    741, 429, 'Mawuena', 'Adjakpley', 'mawuena-kokou.Adjakpley@revenuquebec.ca',
    '707d788edc637f0db0219e19b998deaba01b5918', '2018-04-19 15:59:48', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    742, 94, 'Micheline', 'Wakim', 'micha@deltaxaccounting.com',
    '$2y$10$6yWZpC.dnrWbcPQCaEAlDufI1AmJUgOYF.WZ33DLugzljqbNEHT.q', '2019-02-20 18:50:32', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    743, 208, 'Elie', 'Aboufaical', 'elie.aboufaical@gmail.com',
    '$2y$10$3zQirHXqs0962/zXafpwCeqlHGX4SuRu1.Am5weapqybWTGjLGl8.', '2025-08-04 15:57:21', 0, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    744, 782, 'Rami ', ' Naim', 'rami_naim@hotmail.com',
    '6e1efc0e69940aa3f5af04a6ca2bf0bbc497ef9d', '2018-05-16 15:40:46', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    746, 726, 'George', 'Abou-rjeili', 'gar6139@gmail.com',
    '710411f3ba932a6c1731ef310325817d7cae72d9', '2018-05-21 21:29:52', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    748, 897, 'Alex ', 'Bartlet ', 'chickenranchkanata@outlook.com',
    '9a6aa8b8b6919d3b97d0f40c9eda85f5523c7dd2', '2018-05-23 14:25:44', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    751, 898, 'Ghassan ', 'Sader', 'gussader@hotmail.com',
    'bc61d9a3aef978dd90a43d5d83fdb37c0251c22a', '2018-06-06 20:05:58', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    753, 389, 'Iram ', 'Khan', 'khanhamyal91@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-06-08 21:05:01', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    754, 900, 'Roy ', 'Bartlett', 'roy@caseysottawa.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-06-12 14:05:12', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    755, 127, 'Siavash ', 'Razjouyan', 'siavashr@hotmail.com',
    'b01f67adb17354737d273b0cae8d36366b08af91', '2018-07-03 16:58:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    757, 896, 'Sachin', 'Chaudhary', 'currynkabab5@gmail.com ',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-07-18 14:15:43', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    759, 905, 'Ahmed', 'Saad', 'ahmedsaad03@live.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-08-10 15:14:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    760, 901, 'Joey', 'Aboukheir', 'joey_bruins_19@hotmail.com',
    '$2y$10$tlMNyDXux/f87P6Lg0vhmunlNo3E2zuib5KoRxOj7Qh1OIFB97AlO', '2023-11-14 08:31:41', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    761, 210, 'Moe', 'Khir', 'khirmoe@gmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-08-27 18:40:08', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    762, 863, 'Tim', 'Moss', 'tim@timmosscpa.ca',
    '$2y$10$dRjeAgJRfbZRijCCiMUhtO.57HVIrER7F2aX5KLmf1WFdNbnuFKRK', '2025-03-31 19:05:50', 104, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    763, 906, 'Grace ', 'Chen', 'min.chen0@icloud.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-09-26 13:26:03', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    764, 861, 'Maryan  ', 'El-Khatib', 'jack@pattybolands.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-09-26 14:59:19', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    765, 238, 'Zein', 'Tahan', 'Zeintahan@hotmail.com',
    '7c4a8d09ca3762af61e59520943dc26494f8941b', '2018-10-01 15:02:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    766, 907, 'Mostefa ', 'Mohammed', 'Hollandspizzeria@hotmail.com',
    '$2y$10$0U0t4bBmnNRKl3qacuoJ7OksJAvsKYMFMGJllvVQ4NtrfiVsrtv9y', '2025-07-21 17:57:49', 6, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    767, 346, 'kaled', 'Alkhatib', 'kaled.alkhatib11@gmail.com',
    '$2y$10$8cDyipXQ5fdAdyzfdh3J..PMqjYcj/Zxe9v6Oek6qwrPnurJ9z24K', '2021-03-25 17:53:20', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    769, 0, 'Mazen', 'Kassis', 'm.kassis@live.com',
    '$2y$10$agDZzYN0y17oMKE4D5bPlu4z86nyfowGAGWA0APDlcOIqlq1vCpUC', '2023-09-30 21:14:34', 2139, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    771, 246, 'Youssef', 'Karkache', 'you.karkache@gmail.com',
    '$2y$10$QpbBSUyCp8/H.D9vQXIWRuqq6cR/JlIAdw8fbrrl1OMU1nJtvfCXK', '2020-05-22 00:57:25', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    773, 894, 'Hisham', 'Ramadan', 'gilldan143@gmail.com',
    '971f946a25969fd883ca14d3cc4cdf844adeed75', '2018-12-04 21:27:55', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    777, 920, ' Ali ', 'Khatib', 'khatibali2@gmail.com',
    '$2y$10$ySKvpmJUIXILl2LTuu3W6OriQHgaNxGlBT0vYGiDqSknMf/fIWyQ6', '2018-12-20 17:59:32', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    778, 248, 'Rima ', 'Elmorr', 'rima.elmorr@hotmail.com',
    '$2y$10$3LYlzLIULNtvV3G4Z3ltx.zZeUymQdaHQsGU3SuNqtQX6eIcKAETm', '2019-08-23 18:25:29', 14, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    779, 225, 'Ziad ', 'Kanaan', 'Ziadkanaan2013@gmail.com',
    '$2y$10$t0gjY.gZSZ.egjNSiUr/aeTPw7qBZrEoBoXYfn5v0IVZi4hpNtBJq', '2025-06-11 11:03:37', 2, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    780, 883, 'Lyad', 'Rai', 'alrai1@yahoo.com',
    '$2y$10$VukgmOZ74ISSjA68t0P8/ewYOvgkylljptiPJ0Dt4WsdIrVX3COhC', '2019-01-08 12:38:47', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    784, 924, 'Ibrahim ', 'Wansa', 'bahowansa80@gmail.com',
    '$2y$10$3Cb37Ljf64mO/uB4okvooeAVDe/kpUyRPSuMfMVcOPTcGDN20y4Q2', '2019-02-05 19:29:36', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    786, 816, 'Sam', 'Ibrahim', 'Ibrahim_sam@hotmail.com',
    '$2y$10$xXn7xD7DdJmfkqx4EbzGHOjl9LmW.LxZETEYMwDxRJurfAq6xQW9S', '2019-09-09 21:26:05', 90, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    787, 925, 'Van ', 'Dang', 'phonha2018@gmail.com',
    '$2y$10$YR3s5uXn23rfCADPluSY..Hwasw4peq3qcLENvkWMO3qkFX/QX0nq', '2020-01-07 18:51:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    788, 904, 'Adam', 'Sadik', 'info@sizzlengrill.com',
    '$2y$10$HmLB.RjOZBIaceLlGczwaePpVhCKbNLr9SXc1vu76x9lhK.GhHHpe', '2020-09-14 13:30:25', 10, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    789, 95, ' El-Moustapha ', 'Meski', 'Bartours1982@hotmail.com',
    '$2y$10$ecZp4te3CxsltqZiSYnFo.PFQ4pz/T/ciNvHbtTuoDVoH1k16yDsC', '2025-07-24 02:32:07', 135, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    790, 926, 'Aneesh ', 'Krishnakumar', 'roostandgrills@gmail.com',
    '$2y$10$dkyXgOxPeza6xGFJmEmAjOf1LVcpiEKHayj3qiKHqeV.CcgSjEZkG', '2019-03-08 17:43:39', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    791, 404, 'Nenn', 'Nguyen', 'nenn646@gmail.com',
    '$2y$10$7JMhT68VbEh00BWVTU1ZN.0TOkURjo/VVswRZd/BKyIHJNjWB7aV6', '2019-04-30 19:24:30', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    793, 930, 'Rabih', 'Rabih', 'Rabih2015_01@hotmail.com',
    '$2y$10$VBjX3odn/bYv5sjoodTMperrR1keQXlIuldTsVlI/wbyYsQPNIcGq', '2019-03-26 17:06:29', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    795, 919, 'Eddie ', 'Zen', 'brothers530@hotmail.com',
    '$2y$10$QsDJAnzt7v97DdM3qi3nw.cTecBSVASi1ZOlChOMcxu8O3h.x4t5.', '2020-12-18 20:38:53', 6, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    796, 929, 'Gislain ', '   ', 'dynapro@videotron.ca',
    '$2y$10$DyrgkFNjiZLqPPwnHNnxwOMzNV7DC9kbzY9mXVmj1dr2cEZC8cDua', '2019-04-02 01:58:58', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    797, 928, 'Manuel ', 'Remedios', 'portugalos2015@gmail.com',
    '$2y$10$8AB.HEP250Ji5xHGx3Y3EOUrDljK7zxXVd1ko/xW2yvhhq63NY7.i', '2020-07-15 20:16:25', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    798, 143, 'Youssef ', 'Zaher', 'nathaliezaher@hotmail.com',
    '$2y$10$EP349mtV2b.6IxFVeTupPOIWxFX3RHfUkqYPY/jEcxH1SLwP9Xiru', '2023-03-07 01:58:12', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    800, 934, 'Adam', 'Sadik', 'yorgosbarrhaven@gmail.com',
    '$2y$10$1elMz6K6JLlxyHo8mQLHweVLhLi/aVaOOMGI6w8iHBW4HWVcDIaoG', '2021-05-11 20:34:27', 44, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    801, 509, 'Shaohua ', 'Guan', 'kpboyhua338@gmail.com',
    '$2y$10$77UPtitaV3kwdNRg0Fo9Wu9ucmn6khJ0Eq.mJltgOZf0OmWFXoNJ.', '2019-04-04 17:39:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    803, 218, 'Madhuban', '', 'madhubancuisine@gmail.com',
    '$2y$10$9j7rti0UuZ8VwAGai3cYReLcpvgqs1RusojwUFxzkA.gQj.k2ZgRu', '2019-05-06 18:16:22', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    806, 937, 'Shahib ', 'Elmonum', 'selmonum@gmail.com',
    '$2y$10$njrvtt9kO4p8XbTkpgSGte1DlzDYZN4FtVfvJd86AkxGEl9IfpFnC', '2019-05-22 15:38:00', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    808, 940, 'Tima ', 'Thamniyom', 'timathamniyom@hotmail.com ',
    '$2y$10$RbeQKCtTHheUeSdztwC6e.nTPGrKObkPN0.ilzZVlK7wNlLoUpFm6', '2019-06-02 00:38:44', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    809, 225, 'AMMEX', 'TAX', 'ammextax@gmail.com',
    '$2y$10$K/.NC3JvaFJ5YT/zmJTp7.8h9r6Yupafggdck33EjlLEVOg6ZJF/m', '2019-06-26 17:46:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    810, 944, 'Kevin ', 'Chen', 'mingrong2015@yahoo.com',
    '$2y$10$v9.0w6935mJDcsytoPl40OZGFhYVEuNByBqx/0vWeh.s4PkAe6awa', '2019-07-04 16:58:29', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    811, 943, 'Moe', ' ', 'mchoukair@live.com',
    '$2y$10$rGfjGzvcXK7takntahJi4.ebb3VPPJR4cr34hnABltAa7igyIXNia', '2019-06-27 18:26:48', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    812, 729, 'Ali ', 'Eljammal', 'eljammalali073@gmail.com',
    '$2y$10$CcTLs9DmjIrypzeAsmma7ez/9eEtxYaa95J8FR0/wWvVlySdqXIa6', '2019-06-27 18:27:37', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    813, 494, 'Ali ', 'Sbeiti', 'ali_sbeiti@hotmail.com',
    '$2y$10$j6BuuzwCb/CuxjP6qqAnUOcyDBKRTqbNQ2leBQI.eBj3V0/5oRooW', '2019-07-29 11:33:47', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    814, 931, 'Lyne', 'Thivierge', 'promotionsav@videotron.ca',
    '$2y$10$rGwUc4uzXgX7/MbeIQ95leZb0t42DTa0rLvLwECvNSE2K/4Ieo8TW', '2020-07-02 13:34:16', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    816, 612, 'El-Moustapha ', 'Meski', 'Bartours1983@hotmail.com',
    '$2y$10$UT6Mw8xFCifTjxMYjhWFbONAbDVGwqFZLl949nMrMI/L9nlw.4dLq', '2025-01-06 00:33:36', 56, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    817, 948, 'Laurent ', 'Lamirande', 'patateloulou@hotmail.ca',
    '$2y$10$KJKRQwTn0EnvCIenv7BCdOQ5T3opv.ZawRbQoXxm6YASbdYWuu/ya', '2019-09-11 15:27:26', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    818, 947, 'Joe ', 'Ayoub', 'joeayoub67@outlook.com',
    '$2y$10$RCjZiMr.FcoYtJPDRdE13uAMwEz.4gEIt2kuB0HlBBrXadIxy6C7.', '2020-10-08 18:30:37', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    819, 161, 'Rabah', 'Abou Hassan', 'Rabahabouhassan@hotmail.com',
    '$2y$10$Rh/GxKAiBaq2/PCNLx2gLOrFZ6MHwL4eAgx16eOW3L/EwlBTWTsg6', '2019-09-05 17:24:28', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    821, 946, 'Huy', 'Maison de nouilles', 'huydo@live.com',
    '$2y$10$FoQlqok9T2h82/6stpr3.uG5PDMkexgZI2OYOG5mxmY0JlzqcQ7hu', '2019-09-14 21:18:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    823, 952, 'Youssef ', 'Zaher', 'nathaliezaher@hotmail.com',
    '$2y$10$fVxdanncAo1PiISKiOuQSu7zqpcW3SDs/zX0QrJxSjjdaPJ48d4J2', '2019-09-17 13:08:20', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    825, 949, 'Fadi ', 'Sayed', 'fsayedd@hotmail.com',
    '$2y$10$UDHo6UZ5SV9OarcewqhfK.JE4vXvR.JPUxP.d6/uyvluuDkgdJ9TS', '2019-09-17 19:35:07', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    826, 136, 'Winnie', ' ', 'lemongrassthai8@gmail.com',
    '$2y$10$6Alio6mHqeVmCM.3jYR4guNUC0gDJG.vqSYpfAEltl2/carTMQyuK', '2020-10-02 23:13:26', 23, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    828, 721, 'Ray', ' ', 'ray_napolis@hotmail.com',
    '$2y$10$3Y.THv/T.xwlkgifrFbsce.ELbxwLvUXka3VpPYGYFV97QmOEoxvy', '2020-11-29 14:41:08', 156, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    829, 959, 'Minh ', 'Khuu', 'minhkhuu03@gmail.com',
    '$2y$10$VF3MTT3BxAMsrspoy/B2cud8kNNrHbEhJ2iowlWYTRstyVUp08i.G', '2019-10-11 19:10:49', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    830, 957, 'Abbas ', 'El Arab', 'abbas_elarab@hotmail.com',
    '$2y$10$0t2AReh2iLoqTpad4aZ2De8NdlBop.vGOZYMS6cdx1diJbVUow.Cu', '2023-05-17 19:56:38', 58, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    832, 707, 'Jimmy ', 'Tan', 'Jtam048@gmail.com',
    '$2y$10$uJMhdUJ1O6EmwvfBBCU9duwO7fpGRHw0kkEE.2hEhL3e/zoezLro.', '2025-04-20 07:26:15', 10, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    833, 142, 'Fadi ', 'Nemr', 'fadinemr@hotmail.com',
    '$2y$10$8l5qseARKYSQfMP//AgbuuG/mlLZGnkJ7gCoqEjiINO0KOG/KBJqm', '2023-12-17 14:07:11', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    834, 826, 'Fadi ', 'Nemr', 'fadinemr2@gmail.com',
    '$2y$10$YnR1E3J7N3qifoXXwyveU.y0OYOSXMmQmYiEVFiCWAVUm9drD5Sbu', '2021-04-19 15:55:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    835, 945, 'Eddie ', ' ', '2828eddie@gmail.com',
    '$2y$10$y7Qra0XbsTVWVjRvMRSiaOdjvUwzSX0ivtc88O6/LmWZym.3Zzrb.', '2019-11-11 19:00:14', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    836, 842, 'Moe', '3 bites', 'mrdental@live.ca',
    '$2y$10$vfipyZoZAlbB2EgW3ZtmY.H7hj0xI7G5znvI2Z.rrDP4I8NVvSDrO', '2019-11-12 17:07:43', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    837, 951, 'Hani ', 'Soueid', 'hani_soueid613@live.com',
    '$2y$10$PNZxYz6EFRqvytc8XZZWOe1DYkJ3ayJKy6ZRPrTuQDsGFUfq7dTyq', '2019-11-13 15:54:38', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    840, 964, 'Pizza ', 'Joanna', 'joannapizza@hotmail.com',
    '$2y$10$vGM6lZl4dUDSvuzEur3O6e7GIwPZvi2Z.eohmzw/oZbWlJbBwyGt2', '2019-11-27 20:40:08', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    841, 248, 'Maya', 'Assaad', 'bookkeeping@deltaxacconting.com',
    '$2y$10$UES4HV3M28lp5lRH/BK10.ezQacVFnNLRpzCGZoXqIGuFxIzdkp32', '2020-02-18 20:51:43', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    842, 965, 'Rabih', ' ', 'Rabih2015_01@hotmail.com',
    '$2y$10$uuyx0r9WvGTeXmO9Ypk1l.HMVa4brrz.REn2vQJmJpJ/XI87nexoW', '2019-12-04 18:29:38', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    843, 830, 'Soo Pat ', 'Tra', 'happy_pat29@hotmail.com',
    '$2y$10$f5x8nzsCuGBQEanKi1xF9ezilLnDggHh8slaaipUfdSD51jYJVu3e', '2019-12-05 18:53:51', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    844, 963, 'Haydar ', 'Mohammad', 'info@muncheesepizza.ca',
    '$2y$10$XLYQPE2lhvhoWvubR2XeVuouYa7wAHEBtAe8CrGWg7MCcBbQYu1IW', '2019-12-06 18:03:47', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    846, 968, 'Eli ', 'Saikely', 'info@friendlypizza.ca',
    '$2y$10$Nj.kt3hvm9JI0At/PjMG6eXGT/6lIkOjpZfAY.pKnn0tNk4ABNaRa', '2020-01-20 20:26:37', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    848, 694, 'Yangyang ', 'Cai', 'Caiyang8602@gmail.com',
    '$2y$10$2xlUvDUcjj25oWBJaKXSYuAaIdVA5dzr.3qLtVIBCAcu5rCJipMu6', '2020-02-04 20:32:53', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    849, 239, 'Jack', 'Yu', '449111756@qq.com',
    '$2y$12$5NRYLRfEursPveT6Y5vRJ.pRjFXEkNVe6ge72tWF/y6O2v/MY5/qO', '2025-08-24 04:11:30', 1440, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    852, 969, ' ', ' ', 'ouassim@yahoo.com',
    '$2y$10$.DjhL5J8f1zy5wvNKzv7BuV3esfb8WgNZYHCYZxVMhKHLh1f8quGO', '2020-04-19 19:59:48', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    854, 256, 'Manzoor ', 'Ahmad', 'amanzoor786@hotmail.com',
    '$2y$10$KxzDrgN6FeEmEKKVMcTgqOz0l1od7ZONJkGqdgosqCJtUzzg4mWQu', '2020-03-16 16:18:59', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    855, 275, 'Sam', 'Elsarji', 'pizzatony51@gmail.com',
    '$2y$10$o2aym82wzpA9yt7m7jl05urTe6AWD0MnWXCrOQ4lwP/BP3OfDbGXC', '2020-03-18 16:56:36', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    856, 275, 'Youssef', 'Jaber', 'yjaber@bellnet.ca',
    '$2y$10$RzWwTOkAFu47lw/J.YZvheetP69Ejl/SVvY6tFwyikck6QtLlk6Ba', '2020-03-18 16:58:28', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    858, 976, 'Ryan ', 'Zhang', 'zrf6479390334@gmail.com',
    '$2y$10$7SShlllZNlO3T.13PDhkVe6QtYhqF.7I.5o0qZlu06j98bE2e7OOm', '2020-04-03 16:08:53', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    859, 913, 'Jack ', 'Khalife', 'khalifejack@gmail.com',
    '$2y$10$2tFLHjfwpVCx0s1q1OvLKOkkcBhdww8rcMgeo9OIkdkrH8.8rWaqu', '2020-04-07 13:17:39', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    860, 978, 'Ari ', 'Fezel', 'milanopetawawa@gmail.com',
    '$2y$10$GgflB.fHt0vnjo9tR5w4GueSNCTBSQLYWqgpZwA0FYAXacDqEPcki', '2021-01-24 01:11:09', 2118, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    861, 935, 'Cedrick ', 'Richard', 'r.fournier97@gmail.com',
    '$2y$10$MSYSI02o.LfjpzcAdvQP3.XXpYGvGn/6m37oM6sS/469FxappzD9q', '2020-05-01 20:34:59', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    862, 912, 'Joginder ', 'Singh Sandhu', 'pizzacornerottawa@gmail.com',
    '$2y$10$UDU1IxHMoBTZk/hi/w5ZIe89kAU7nRcCfhZU0BKS274x9myZi1PZe', '2022-01-04 20:41:32', 16, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    863, 0, 'Resto', 'Zone', 'contact@restozone.ca',
    '$2y$10$LaJU6pHcUPh6/pAlCddmv.IOtUQJQ0PvQBBxbMPcZr.OXd4Wvsr8m', '2025-07-18 14:23:12', 16, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    864, 967, 'Gagan', 'Virk', 'gaganvirk93@gmail.com',
    '$2y$10$KlvsD.To/nTzHphN1XFnm.6zJCfZnazSkLw8fl.txyFUjRc/IJU/i', '2020-11-24 17:39:20', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    865, 974, 'Francois', 'Kharrat', 'francoiskharrat@gmail.com',
    '$2y$10$MizXphPVTRqJV29PAtFfbu17.qM6HtVBhBNiX.oweyXMhD7V3d6DO', '2020-10-06 20:06:53', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    866, 956, 'Sonia', 'greber', 'l.sonia2@videotron.ca ',
    '$2y$10$HuVmbYYu91TEQYJbtdMtX.GCwYtrriguJHmWBx5QjpWfyUAEk4yI.', '2021-01-21 18:38:00', 19, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    867, 956, 'Sonia', 'greber', 'promotionsav@videotron.ca',
    '$2y$10$iAZwHdfcQPtqQtAEjApA0uTTilkEF/TA6pgSLmAhX62h0aOBFjEIi', '2020-05-29 14:58:59', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    868, 140, 'Min', 'Cypress', ' tanxuemin1977@icloud.com',
    '$2y$10$qDDnldKk/b1c0fRanT142evJlPtW9mBYCNYnc1QtMBcBas0.qL6uu', '2020-05-29 15:25:50', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    870, 973, 'Michel ', 'Kanaan', 'michelkanaan@live.com',
    '$2y$10$ovVBDURmKkvEP7k.AugRrOsqWkQO4i844j.Srwyv2Sqv8s8YI5G1G', '2020-06-15 13:28:20', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    871, 295, 'Michael', 'Huang', 'openriceasiankitchen@gmail.com',
    '$2y$10$TTnoAKi/N6HzLR5Eizyi..qK7AUC4GV9g5SM5Fdv/pHlHrTECbbsm', '2020-06-30 20:58:17', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    872, 985, 'Mei ', 'Zhen', 'mayfeng198@hotmail.com',
    '$2y$10$W27CkulQl8WRLjYdjqEv8eH1AvUvGNRGQcKMcwJMznYu6B7xEbSXa', '2020-07-09 20:21:39', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    873, 987, 'Jacob', ' ', 'milanomerrickville@hotmail.com',
    '$2y$12$FtjrWZQkpSSRrJCw5K66Zu2K91tCwOgiLPIAfCmEyeD6kpd8J7SQe', '2025-09-03 13:50:41', 6, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    874, 986, 'Deepak', ' ', 'admin@rinag.com',
    '$2y$10$q9MlQezPYqwBvri3tFJzIOF.VlitRxXl/rQs3n6M2C2SU3WTbTC1a', '2021-10-29 14:13:29', 35, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    875, 983, 'Charbel', ' ', 'salathaicuisineinfo@gmail.com',
    '$2y$10$WQOAxsWgUT75tZuDng7Zke6c5iFZYM2WAAoFCWH6/TuVdi9NOZ7n6', '2020-07-25 16:57:43', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    876, 391, 'Dalyan', 'Akdeniz', 'dalyan91@hotmail.com',
    '$2y$12$Eh6u/uRz2uOQZ4bv5QZ5R.jgFRK56BfVMyzt16QXw/KqexPWuNn0G', '2025-08-18 18:02:23', 28, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    879, 228, 'Jihad ', 'Ibrahim', 'restaurantchezgerry@gmail.com',
    '$2y$10$6DNmopubSilv.mxNNNhRjuSBFi0ztqiji8jb1h09fRcvaBw2fNfdG', '2020-08-04 16:12:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    880, 988, 'Bob', ' ', 'bayazid.bahramiwand@gmail.com',
    '$2y$10$sTh9ZJpJR.DWGZHw.xT6XOJryJ2HnhdJhLFk3XsYjmAYnyfHaZjVm', '2024-04-18 13:04:41', 38, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    881, 904, 'Zain ', 'Sadik', 'info@sizzlengrill.com',
    '$2y$10$OKSdgvflQXXe/mUvKhDmDu07iKdRGIvDhDcd/fEEO3VgbdQeVwOxS', '2020-08-19 15:16:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    882, 956, ' Line ', 'Thivierge', 'promotionsav@videotron.ca',
    '$2y$10$wTebO94H/DOpaLeh9eAukOUKKJUiQ23jhlsPCa7N39KRXjWhyZTui', '2020-08-21 14:17:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    883, 923, 'Abdiwali ', 'Siyad ', 'jimmys_pizza@outlook.com',
    '$2y$10$hXAOWzLY9BT1R5wsMe.Gc.6Fvz6P7IMmKWtDRkX9JThMPog.G8JtK', '2020-09-22 21:50:52', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    884, 286, 'Vivian', 'Tran', 'kimberley06062006@yahoo.com',
    '$2y$10$PoxAJZMLShBWmhNbbNPB/.7wxWomUdQZ56blTfIZt3vnmY62G5ILG', '2020-10-19 14:42:18', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    885, 995, 'Nick', ' ', 'casagrecquegatineau@gmail.com',
    '$2y$10$gpw6JsET723VqerbkoCWJuy2BGFtsSitEAfJZyuZ0nnyGl/R4swES', '2020-10-19 19:43:26', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    886, 985, 'May ', 'Feng', 'fullhouse888168@gmail.com',
    '$2y$10$Xebgo8lEt71HIjmTKxkcwue6IJJVZ9dpJhi66Mr89dN0wysD2HwpW', '2020-10-20 19:42:25', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    887, 133, 'Priya', ' ', 'pmchb2@hotmail.com',
    '$2y$10$lHJWP0ci7CXWVFXW4YNWF.tECI.nu6cdCNHhoOR0DpHxj1wRYOlZy', '2020-10-29 21:15:12', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    888, 722, 'Saleem ', 'Karkache', 'skarkache@gmail.com',
    '$2y$10$vypMjXyHOHjyhRmWOk/JcuMKjs1hwVrFmxMblWK0QKyUFpIuvnKeO', '2020-11-05 16:40:41', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    889, 145, 'Nishu ', 'Mangla', 'Mrmozz.nepean@gmail.com',
    '$2y$10$ap2wzFPMxgUmZAL93.WTdOlYvXBNYZ2Qifa10LRvT8p.GKkan3ZmW', '2025-05-21 17:49:24', 22, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    891, 763, 'Dalyan ', 'Akdeniz', 'resto-marios@hotmail.com',
    '$2y$10$ywSH0O87h0CacAT2nP80s.L32XZT2/WEUIfigayeKwqUg5xy4.MT2', '2025-07-10 13:27:04', 28, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    892, 999, 'Remi ', 'Fournier', 'r.fournier97@gmail.com',
    '$2y$10$RRSWh6Qbyv8z6lVoYHoQS.2fvdlLQRj4FpAVGjO..QQ8JYRGnfUpG', '2021-08-16 22:08:19', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    894, 919, 'Elie ', 'Sarkis', 'eliesarkis@hotmail.com',
    '$2y$10$k7qwk.9XmYz7UozEcES1qOxdFuVfgdtPSziNKS5NjEcT4WzOfSLy6', '2022-12-12 18:09:54', 54, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    895, 1001, 'Tran', ' ', 'tran0180@gmail.com',
    '$2y$10$Ir9E06shzMvBj5JdEx/56Oow0AT82iLTsTpr.YdE52D4R15Yidliq', '2020-12-23 13:04:30', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    896, 1003, 'Charbel', ' ', 'Charb_k@hotmail.com',
    '$2y$10$rRfepriyKhkBkdtjwUF9s.puhRx133j503NZ2GCRiK./L6Lih3WT6', '2021-01-04 13:51:00', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    897, 1006, 'Calvin', 'Ha', 'calvinhakx@gmail.com',
    '$2y$10$b79jIr2lh3q8SaSnu/Qoku0Kk8rEzN9sT/GAp3VNSa18nqoA7UrrG', '2021-01-08 00:15:14', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    898, 1003, 'Charbel', '   ', 'charbel524@hotmail.com',
    '$2y$10$D8hjLxohmdWg2UJ1fchzAeqjDOOEJV4CH0xQG1gxBXJAO24oikrzK', '2021-01-19 21:01:01', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    899, 1000, 'Charbel', ' ', 'charbel524@hotmail.com',
    '$2y$10$y2BM7n5TfV6FzO87jrr4YOoKEUSO0QQIBt3u5/Dzuib4BtZ8vVcZK', '2021-01-19 21:01:31', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    904, 494, 'Zerzaihi Houssam Edd', ' ', 'Bashadz2021@gmail.com ',
    '$2y$10$ZPxEi/IodskcQDSNfq5HrOiiijIpFc55R.wQbEzdkVhJjPRty55cW', '2021-02-08 18:07:06', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    906, 1009, 'Jasmine', ' ', 'jasmine9010may@gmail.com',
    '$2y$10$.00luCqzfmRL3Kn8E0pZie2/odkK71Thwbg7FQ5HBQrI7ujKEFy6O', '2021-02-12 09:03:57', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    908, 810, ' ', ' ', 'funjunction@app.hubdoc.com  ',
    '$2y$10$wtIi0e.2C4Z.t.Se3GJE4O9G1Ij4UrI6ELAZDtPkk7ULkMmtFfgE2', '2021-02-25 17:25:41', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    909, 981, ' ', ' ', 'mico@funjunction.ca',
    '$2y$10$Xo61pdnUV5li4kS1.w6Uy.V5KitChAEcg.c5XJgSe9lGpnkBO5ZH6', '2021-11-26 21:37:39', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    910, 1013, 'Mahde', 'Ghandour', 'mahde_ghandour@hotmail.com',
    '$2y$10$pre4oyk/C.3PVRRKrvao0OUkJ/zvPLVt1SMHI/W.IYIrRJvtjI4p2', '2021-02-24 20:31:28', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    911, 173, 'Roula', ' Issa', 'roulam@hotmail.ca',
    '$2y$10$KyNeh/ug9Ks1LUv6SSiNXuCY0ZmR/SU6SCNQ72Lp3EP1A7Aoy8.Q.', '2021-03-05 19:04:46', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    913, 756, 'Mirco', 'la difference', 'stefanovic60@yahoo.ca',
    '$2y$10$tewbKz62rObli1KAhlFF6uxBjQrlE.LpReXhxPzN8n5ayuLoyxvRC', '2021-03-24 20:03:17', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    914, 756, 'Mirco ', 'Stefanovic', 'Stefanovic60@gmail.com',
    '$2y$10$.qRnrgRrla6vK9jWMiY/iO1.Z2Z7hDbSU3piAPhnuK1zxt9Da114C', '2021-03-25 16:33:25', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    915, 172, 'Walid Abdul ', 'Samad', 'abou_wadi323@hotmail.com',
    '$2y$12$5pVzMsVbpauzSsG7AAQstOF3J9kXQ6AndNi0Gq.vTdyrUs8cIlc7i', '2025-09-11 20:18:44', 4032, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    917, 1015, 'Mojo', ' ', 'mojoschinesefood@gmail.com',
    '$2y$10$yRz9dl/m735u0Wqth5ejReh/gFh0Ihwq4YEXbMMqRzKZFhcwqvJaq', '2021-04-01 18:41:54', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    918, 736, 'Yussef ', 'Ahmad', 'yhaydar78@gmail.com',
    '$2y$10$pT5AIcGLrXTYiptQBbslt.RMPRnshWbZ6QBNyTfwKftguXXDVuV2O', '2021-04-01 20:03:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    921, 415, 'Tamara', '    ', 'tamara.zc@hotmail.com',
    '$2y$10$XfnsEUzndPn4QMdMTPj9DO9M9wGQqpK.KYBxpDGTpzXVLYKFVQWzK', '2021-04-12 15:05:12', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    922, 1016, '12176491', 'Canada Inc', 'Argosottawa@gmail.com',
    '$2y$10$Ru8wiWHi0n8qpabprwTZXuKS8sZI34pTPrOWlufsoIuIj1oVOPvIS', '2024-08-22 14:38:36', 9, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    923, 411, 'Brian ', 'D’Avignon', 'brian@crustandbeanholdings.ca',
    '$2y$10$6T81oN0CNTMCq.cbmMmOyeE7N91KCZPy.9Lehy3bT2DmoSYKuM14i', '2021-05-03 18:19:57', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    924, 840, 'Kaled', ' ', 'kaled.alkhatib11@gmail.com',
    '$2y$10$sYm/Nm6CEMoxweT/gpkRvuhQnga32EsK4POmEp1YRS/L.KPaUgyby', '2021-05-04 14:09:57', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    925, 921, 'Ali', ' ', 'alineachkar1@icloud.com',
    '$2y$10$4Irx2SiTGh8NIywm2RAskem0HoD2wF/jH4ADp3I4bySMHHxDlzUx2', '2021-05-13 15:16:25', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    927, 411, 'Donna ', 'Duffin', 'donna@ledgerlady.ca',
    '$2y$10$4liwWxymBvoMRPKE8D9IVOZV48LOKnCtUGxtMgMfCvbbPQKtPEz/K', '2021-08-13 18:27:09', 8, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    929, 1020, 'Tri ', 'Huynh', 'trihuynh1266@gmail.com',
    '$2y$10$YxodmUvDU0BMYCKHlJaT8OJkK3715ey5W66Ta.0.GmqSuEQP.5VKm', '2021-12-14 09:36:40', 10, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    931, 532, 'Tim ', 'Middleton', 'middlett76@gmail.com',
    '$2y$12$8/FNY6x/3tMlJu5q5y0glOQ65Nj7Jh88i.VnwcrfCWIZCWs5Ul78y', '2025-09-04 18:16:26', 157, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    932, 651, 'Pha', ' ', 'v_keov@yahoo.ca',
    '$2y$10$wwULzF8vwE.yopXHr70Tr.RtwQR8nhZaY1vV7cJSo07zYD1ccyNQm', '2021-12-25 08:05:32', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    933, 334, 'Peter ', 'Dahoun', 'colonnadepizza@rogers.com',
    '$2y$10$/wJkH61bMT9qVaM70ZMOneEWfB5QZ6le9.W5kwY.Y8mBtZYTxdvmu', '2021-09-30 16:11:49', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    934, 1027, 'Joe', ' ', 'colonnadecarling@gmail.com',
    '$2y$10$YbuyRzZksMoM42lEX3FY..jQ2xKhMWrPiUVtFZCsLm4VLM5hmDopK', '2021-08-03 16:07:34', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    935, 1024, 'Lizz', ' ', 'Colonnademerivale@gmail.com',
    '$2y$10$KH9NUpQe0gT2kU14I9dR7eM6vxM305F67ZeNlaw9fRkb2ZhaVKbU2', '2025-03-21 23:32:44', 736, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    936, 1028, 'Maamoun', 'Araji', 'maamoun@Araji.com',
    '$2y$10$E20AsrAWziuVBba2NzC5j.t2w1W0krUdtL50erBk2NS2X9VrJFm2y', '2023-12-22 17:38:48', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    937, 1023, 'Rafic ', 'Debian', 'raficwz@hotmail.com',
    '$2y$10$r2IyOR7mJhybYnbvMs3ADey6uF03F2kDZRpQgOfOGl/YPMtjmUwo.', '2021-08-05 15:52:40', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    939, 861, 'General', 'Manager', 'gm@lorenzos.com',
    '$2y$10$iwYZz82j0A6A9u/ngsLxQO7B2zqcejvTwwNQvT.Tp57yuqXK1vy3K', '2021-10-14 18:04:05', 26, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    940, 998, 'Farid', 'Hashemi', 'Fariedliv@hotmail.com',
    '$2y$10$ujbvEGIAEsZCi5wBGrC5r.AC3WCypFblQfK3gGOX3FugtHtjANVi6', '2024-05-25 02:41:37', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    941, 768, 'Yu ', 'Tian', 'yutianv5@gmail.com',
    '$2y$10$X7WqT8FXiBzbkS.WhsrUS.6jP39QA05OiL.pDHMqLmqUKakzh0Yqq', '2021-11-01 17:42:07', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    942, 1038, 'Mahde', 'Ghandour', 'mahde_ghandour@hotmail.com',
    '$2y$10$brcRvEkOJ/ViTMjISjPPDutjB1/FJBcW73qzhF6bCu8W7mu.x25Zq', '2021-11-22 15:41:34', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    943, 1030, 'Dalyan', ' ', 'dalyan91@hotmail.com',
    '$2y$10$icrAwpB06b4fAEykjAxdP.JJ.InuTnvW5BFv6e1QgIi3uHjDtpKeO', '2021-11-22 15:57:36', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    944, 877, 'Matt', ' Lemay', 'mattlemaybooking@hotmail.com',
    '$2y$10$.kysjJGpa2zIdMaVlO1hCu/uPqD/W9DFQOMd6ohBsra7rqL0/E2ue', '2021-11-22 15:59:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    945, 1037, 'Adnan', ' ', 'adnan.ramadan57@gmail.com',
    '$2y$10$odwO55O/fqWghCmpLbeS.enF9faBd6hTFR59sgLyhEhJcAMiC37xm', '2021-11-24 19:21:08', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    946, 189, 'Mohammed ', 'Abdullah', '613andiamo@gmail.com',
    '$2y$10$DyV9eW2mbQcpbXWZpZseEe8RsOd3c7i0pydckxoZRPZlzdCaPi3zS', '2021-11-30 19:39:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    947, 953, 'Kaled ', 'Alkhatib', 'kaled.alkhatib11@gmail.com',
    '$2y$10$sFRfNF82RZQiUzLgcjv7uOeZd8nSZzU0IDuh572AQeqi59AB1L6FS', '2021-12-01 19:11:20', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    948, 764, 'AAghar ', 'Schokohmand', 'nargesalamy@hotmail.com',
    '$2y$10$220js/9hFoJXqgnkMj8nIuaYQzDVSyUB.szxYvm978GBZAX6Ni4Fi', '2021-12-04 21:43:47', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    949, 205, 'Ali', 'Nassar', 'milanopizza.casselman@gmail.com',
    '$2y$12$EFViwxK2io6W1zgG/ECtxe8XEkPQBfoCg8BHdGWpS7iC/K8rNxEyC', '2025-09-09 17:04:53', 22, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    950, 1035, 'Dumpling', 'Bowl', 'dumplingbowlottawa@gmail.com',
    '$2y$10$Su3CeMsU5IFYNcXNEHOu2OM7jIHd54dZszd6cL9yPXgTS8Ly82ccW', '2022-10-26 18:11:11', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    951, 1040, 'Nick', 'Konsoulis', 'pareaorleans@gmail.com',
    '$2y$10$RXMXwPN0uWiXAc3J0EQACe5H/P4zz5t8OWc15dtlcT5IpNKEdAmty', '2024-08-24 16:06:12', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    953, 1034, 'Hisham ', 'Ramadan', 'gilldan143@gmail.com',
    '$2y$10$5ITOB.kjOXuF5MmAcHVvaeJwAcvsG5Pd2eKMxTnyF7A6hZXfpabM6', '2022-01-13 11:46:26', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    954, 1039, 'Khairullah ', 'Faizi', 'Khairullahfaizi@gmail.com',
    '$2y$10$YeEWSVO7hN2Y9niuSbcVMOS4j1IU.kNzxQkjKPhOm67Sl5ZsxViGW', '2022-01-20 19:06:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    958, 1045, 'Jack ', 'Khalife', 'khalifejack@gmail.com',
    '$2y$10$o3yVZMMtUdJt.jgmBPRFM.BpFeIK9L7wkm4OLJ7Z.3ReOj0JwxFfa', '2022-02-03 15:15:39', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    959, 1046, 'Jack ', 'Khalife ', 'khalifejack@gmail.com',
    '$2y$10$bqatf.iEZHOeuaPsSrW0auyHmLpnw8DQjGfz4.Ix1Z1ZCozlrAbL2', '2022-02-03 15:16:09', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    960, 0, 'Mazen', 'Kassis', 'mazen-milano@live.com',
    '$2y$12$TQf.toW97JZo6NDiPJHFQ.qdX5Q3Ge.8o2u/mSNb9fDV.uVLdc5ei', '2025-06-05 16:41:34', 76, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    963, 255, 'Scott', 'Budden', 'scottd.budden@gmail.com',
    '$2y$10$Yaoa/z4GwcuKnQIhbGlCBu52/1H3xxbZcPRFn4p/sVd/SmK5ifNO.', '2022-08-24 02:19:39', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    964, 1042, 'Mohand', ' ', 'mohandkacimi@yahoo.com',
    '$2y$10$Scbz4y9PD6F97rsQMUHKJ.MuwXmGd4JNcS1p2u8twLxziITwdT.ou', '2022-02-09 21:37:59', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    965, 838, 'Moe', 'Osman', 'osman_moudi@hotmail.com',
    '$2y$10$QjZLHl3shK2ozFXN13dZfeUl.70vGm.2d/DSftrp.9EWrqHBU2bZe', '2022-03-01 19:36:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    966, 1041, 'Moe ', 'Osman', 'osman_moudi@hotmail.com',
    '$2y$10$WPDI7SoRfHY3CyZ/BTuam.h8MqPfJMgQxnr/MqZKRu.t4cO14f5t2', '2022-03-01 19:36:39', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    967, 128, 'Andrew ', 'Youssef', 'andrew.nypizza@outlook.com',
    '$2y$10$575Tglv.XkNwslqGyy4tnOk18wyIUWtMj59xzDVmLQ346.A3P0VXG', '2022-03-11 16:08:44', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    969, 1044, ' ', ' ', 'thecupboardrestaurant@gmail.com',
    '$2y$10$Cjg3nw5FoS55ucbDm8RSd.v6NNqW1h4hXu34kw53S4IHx3JuWud/6', '2022-03-08 15:13:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    970, 1012, 'Pierre ', 'Ebrahim', 'Pebr35@gmail.com',
    '$2y$10$u3LV8XkNLJRc1q9IrffkAOR3PLfQ6kXhzWNYb/k47PJxIdNoXq/Ru', '2022-06-11 01:14:20', 6, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    971, 1048, 'Somjai', ' ', 'usaw658@gmail.com',
    '$2y$10$J15rvfG1YFoDaf7GXuavYOHUHDUwgkjhNtPrrhqjQ/ghLkJnb1vhm', '2022-03-31 17:08:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    975, 1054, 'Nicolas', ' ', 'nicof1995@hotmail.com',
    '$2y$10$BJOHOrjpAhQm/xxnWLb.p.V1GaPwIsgKEaeOtV3.V84UD.9ULKNOO', '2022-05-24 09:14:56', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    976, 1051, 'Ali ', 'Al-Tawil', 'aaltawil94@gmail.com',
    '$2y$10$AyAkeuDAhHzW580l09FmEesKemiN4lRAI8bX2dBXkjicIUnpEbDae', '2022-05-25 17:48:26', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    979, 825, 'Nicolas', ' ', 'nicof1995@hotmail.com',
    '$2y$10$jxp5NiBYDY.SJusVHX5Lye6MsWUGqhRJgW9hng8En2tGmi4Uq8Eye', '2022-06-21 16:14:54', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    980, 1018, 'NUAS ', 'YAS ', 'nuasbaha123@gmail.com',
    '$2y$10$6/HD42ev2UvU3RWiCAcLS.aIkXPNKT.RgThe1huEtTGHxHdcB5/yG', '2022-07-14 09:27:37', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    984, 0, 'MOHSMMED', 'AMER', 'CALLAMER@GMAIL.COM',
    '$2y$10$kIBAYajA7ZleqkuruhQ7Q.XPfRk6/GTPj5aFTWrlO7ICR9YLa9kfC', '2025-06-08 00:48:34', 619, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    985, 512, 'M', 'Tabaga', 'milanoosgoode@gmail',
    '$2y$10$py2DsIieDDPfugyDjRqbF.Qo64v1BKgiaQY01xHa1GErK6hQSYbCS', '2022-08-30 14:54:49', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    986, 889, 'Vishal ', 'Patel', 'omnamahshivay.milano@gmail.com',
    '$2y$12$h4IViEnTC/0xbcfJhfnz/.MBZ41CGS/OQb5tMCTaT3LNCzKXtOM2C', '2025-08-24 06:47:32', 807, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    987, 850, 'Yousef', 'Romaizan', '8215557mainstreet@gmail.com',
    '$2y$10$tCUZAnE38IQXLHMPTuvbhedZxG0U/zHzYRhWQki1vrQIq4EvCXj1W', '2024-05-20 19:42:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    988, 0, 'Fouad', 'Daaboul', 'Fouaddaaboul1@yahoo.ca',
    '$2y$10$M4/ZjPVrNxEMqwx4dem..eEBZiaJB5mRX0K0KGj6lh8FBUApuALzK', '2023-04-24 09:55:26', 20, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    989, 1059, 'Golden Center', 'Pizza', 'Goldencenterpizza@gmail.com',
    '$2y$10$bvU/Wja3tHPuMw/fH5KzZOby4f3f4r6B50P5VdqsdJJVezqpTuhW6', '2022-09-23 14:31:40', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    990, 1060, 'Joseph ', ' ', 'Josephnicolas@live.ca',
    '$2y$10$2DZw5F70YEJqpKP7vREXxOMeaBfBqSdhWT3l9Il0/AAAff9lVc03m', '2025-07-21 13:22:23', 0, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    991, 970, 'John', 'B', 'johntheboyo@gmail.com',
    '$2y$10$zUsgSgZqutcqliMrYbgFsu1V.qOFqJO/iyqYRxMOCX7KYQJ1VScVS', '2022-10-11 19:57:43', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    993, 1061, 'Pizza', 'Times', 'a1pizzatime@gmail.com',
    '$2y$10$qnXmlJ3ypE.8s6X0ZHRQlu9mbmxl5I51YPukuArPfhQ/R0hVjczCG', '2022-10-24 17:10:38', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    996, 203, 'Somjai', 'Champa Thai', 'Champa.Thai2022@gmail.com',
    '$2y$10$7No2n6PMcqHVRuIFZkz8N.r7ZlWT2orQRGTIWJXmhUNht4Ny19XXW', '2022-11-08 13:42:05', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    997, 255, 'Herman ', 'Lo', 'herman@cpaplus.ca',
    '$2y$12$ku0PIIj8jhRS247JbNAAyOXOdWnengQcO.hENl4C0eZZEPTaUEtM2', '2025-09-08 14:30:59', 37, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    998, 209, 'Alison ', 'Oveissi', 'milano1287@outlook.com ',
    '$2y$10$d5QD7TvqEGcTXBNHJqPhaObE7ZXeXCRoQkfs6IDx6esifWClLxGU.', '2025-02-24 18:22:24', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    999, 1052, 'Fouad ', 'Daaboul', 'fouaddaaboul1@yahoo.ca',
    '$2y$10$.5rKQJIGaRqlTOLZ4FF7zOl5hhyOsZPBsYs6LIaphoU3lk.OS.1HK', '2022-11-23 21:07:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1000, 328, 'Ellen ', 'Benson', 'ellen@deltaxaccounting.com',
    '$2y$10$ZmNAZpmPGLI0RqsosEXKSeEQf6VQlP7//n6eIDykiE6ap4Fd9ef9C', '2022-11-25 20:06:15', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1002, 1062, 'Patel ', 'Vijaykumar', 'milanorockland@gmail.com',
    '$2y$12$opapU1GxtqCZ68uQuJDgYOp3bhae9KmDt851h6ROOLy62ZMnpNbG.', '2025-06-21 15:35:37', 7, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1003, 193, 'Senthil ', 'Kumar', 'houseofgeorgiepizza@gmail.com',
    '$2y$10$5tcorlEE0cjIw9b1QKxZHeU.vpUpuGJlpbyVrTvtk18cbkZGqbC5S', '2022-12-12 18:31:20', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1004, 921, 'Wadya ', 'Khaiber', 'wadehkhaiber@gmail.com',
    '$2y$10$BW7n9yuIx4LUqo4yJQv8qeJss42wp2nlatDGhqRImtylvzJmGJ74S', '2023-01-24 15:53:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1005, 182, 'Jean ', 'Hajjar', 'jean.hajjar@sympatico.ca',
    '$2y$10$CIS5xucLJk187hNBoBI6veEObeHIW.okHbKDnt4ILfgmbslOrOC8q', '2023-02-21 16:34:33', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1006, 989, 'Hamza', 'Rashid', 'milanopizzahull123@gmail.com',
    '$2y$10$2GDDtxqR6IOgSKt266qOieH4gMQ2nRg43kDDUw2OrQ0EmoR/sl4NK', '2024-02-25 04:07:44', 13, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1007, 1016, 'Dia', 'Amidi', 'info@argosgreek.com',
    '$2y$10$SyBuzEyNv6O/gowYGTvgEeEWukurAkeMf0BTQmdmh2vzorXO728t6', '2023-03-03 21:23:36', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1008, 833, 'Parthkumar ', 'Ashwinkumar', 'parthkumarpatel93@gmail.com',
    '$2y$10$.rT6LxSqMj9/SHwzLa05bejky16gzr66Ddlb/wHm6xnTHiLWkUYdW', '2023-03-06 15:26:23', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1010, 1072, 'Xian Fang Situ ', ' ', 'xianfang8822@gmail.com',
    '$2y$10$s0LhlR0Q/1jkhdpxiUyuoOGtuKRQ/SlQcHTi2L1ECK9FF01Wtom1i', '2023-03-15 23:48:49', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1011, 1069, 'Patel', 'Pankitkumar', 'pankitpvp@gmail.com',
    '$2y$10$6xvscdBeHdKgGZWtdlt6me4d4QWgsg6ufH4l8JrJMCR9ZfkPqfGC6', '2023-03-22 16:08:25', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1012, 1073, 'Mahmoud', ' ', 'mamoon995m@hotmail.com',
    '$2y$10$Wf8SLL1wVQ6mCfaOq8L1TeU9E52LKq8M5cFK8K824Oio3.kQWYfp2', '2023-03-29 19:27:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1014, 392, 'Amandeep ', 'Singh', 'amandeep.singh06@hotmail.com',
    '$2y$10$5tsNLjQL49k1JXsMoNBMie3iuJtOoRDJuIJ5FhCTfOvlWTfkFMgSS', '2023-08-07 19:39:43', 4, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1015, 0, 'Mohamad', 'Lezzeik', 'm.lezzeik@gmail.com',
    '$2y$12$MSsSg.Q5Sz/5QBfDn798VueNx.q9KvrL5g16oiesOYuR0ZovwmubS', '2025-07-31 08:51:29', 35, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1016, 453, 'Shamiur', 'Rahman', 'sr@fatalbertselmvale.com',
    '$2y$10$XU5bmv4aIAqDtciuIPXBz.g0/3S4NKzZICGWjQaWy/O3EMfnIK7ve', '2023-05-02 20:24:02', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1020, 183, 'Diana', 'Accounting', 'diana.s@accounting-plus.ca',
    '$2y$10$62voGzDClJ2njmiuODq5bOyuxIDzVa/KMQ7epZ5Nh6oPb0YIn3.HK', '2023-07-27 14:16:14', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1021, 184, 'test', 'test', 'tester@tester.com',
    '$2y$10$Djt2XecnCbCuNoSN5N0Vt.4PFTgc6ouy/iEjREQ6y49BXvbOEL4OC', '2023-07-24 16:03:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1022, 1078, 'Apurva ', 'Gondaliya ', 'mapledelightpizza@gmail.com',
    '$2y$10$/P4jQ3KSNNSBjVvUULY9nuf59wjU/8p7M1WbphWjOH3jVZLSgSDnG', '2023-07-28 15:44:54', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1025, 392, 'alex', 'nico', 'alexandra@menu.ca',
    '$2y$10$6EkzrQCi8DZ3PgFZLU6qyuuHi3YyKHzPTHgiUd3l5U0/c6qi7Q.IG', '2023-08-23 13:20:20', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1026, 114, 'Alex', 'Nico', 'alexandra@menu.ca',
    '$2y$10$9EcumuknRmGKDOjJlEVfdev8Vpv7Akjw7yEaY9E3jspwUvHFD4KK6', '2023-10-24 18:43:26', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1027, 1080, 'Mahde', 'Ghandour', 'mahde_ghandour@hotmail.com',
    '$2y$10$BtBZ1yt7TvJ1aTQBCbIKP.SpwiN6j6Ams5ZbNCv93LctBAFI.tdGq', '2023-10-29 13:10:41', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1028, 134, 'Mohammad baker ', 'Al-Khazaali', 'houseofpizzaorleans1@gmail.com',
    '$2y$10$J0SzCHfpGRAKfmnlQwm3uuG6x.sNopvdbAFrn6AZW8a7/VDEA66K.', '2024-06-04 00:51:07', 5, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1029, 1074, 'Vijay', 'Vinodkumar Patel', 'vvpatel2196@gmail.com ',
    '$2y$10$WdkKb2s69ZMuTI45Df5JieooK8J/OJIqN3z8K3mze8rdvuW55AI9C', '2023-12-05 00:55:43', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1030, 1070, 'Ejaz', 'Butter', 'lanawab4@gmail.com',
    '$2y$10$fKtLxejclP8tPmPO73NtQeUx0FcjiHI5vLR7eE4shJWROp2z.dULu', '2024-02-20 18:02:49', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1031, 807, 'Nikantkumar ', 'Bhatia', 'milanoarnprior@gmail.com',
    '$2y$12$dmdCoUBZyZlrcvOM5o6XgeleH9lohXie4XCoJmvhZcunWsQunjTxq', '2025-09-12 01:19:20', 2500, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1034, 1081, 'Vishal ', 'Patel', 'gajanand.milano@gmail.com',
    '$2y$10$eX9nuy8L4qO5Mx666lQriOBbyceBlLyBTTcBeEQpnd2jNk/z/4/Ty', '2024-02-05 13:58:40', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1035, 1063, 'Mitulkumar', 'Kakani', 'northgowermilano@gmail.com',
    '$2y$12$Pp/qiMPHurgfvhxwKGL2pubbeWzuNze8x8rvxDGL2dEr9hdbEkDnG', '2025-09-10 23:18:24', 209, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1036, 312, 'Chao Wen', 'Zhang', 'mikisitu9138@gmail.com',
    '$2y$10$8xALP0i3jNYgzO/WWWnPIuI2dEgBELCMGsO2Iz/urQjDg79WC1kmK', '2024-07-12 17:28:07', 19, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1037, 1071, 'Mahde', 'Ghandour', 'mahde_ghandour@hotmail.com',
    '$2y$10$DmKOQ7I0ZDJYgiYXKgnXkus0NJYZIYO0oQ7wG5a2Y3CmnswkpQRZe', '2024-04-01 17:32:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1038, 1025, 'Naman', 'Bhambani', 'Pulkit@colonnadepizzas.com',
    '$2y$10$8SBsrKJAVefNFO4gN8rUaun7gK/wVjVefRV1GYUUJy2mHaa7pmkPG', '2024-12-10 18:18:38', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1039, 1084, 'Ari ', ' ', 'Milanocarlsbad@hotmail.com',
    '$2y$10$BHjNE4AO3dF4WibhO1oDwO28vZZKEGYnUnCQ6dXXvJIFZ9MYBz.sC', '2024-06-10 14:11:05', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1040, 1082, 'Bipinchandra ', 'Patel', 'Bankstreetmilano@gmail.com',
    '$2y$10$eX5Zn5pH3oEWThlTnmUDw.Jk/n9.n/18q3g7Wq0FjVVLfbE8jOoha', '2025-04-30 21:49:38', 18, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1042, 963, 'Mohammed', 'Nawabi', 'mohammednawabi711@gmail.com',
    '$2y$10$b/1WECyrT//xvgySy9TL7eQTwvYrRpRg8cBzyjWcPsEtpXuuHlMUi', '2024-07-11 17:42:35', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1043, 963, 'Mariam', '  ', 'mariamn01@hotmail.com',
    '$2y$10$/tWWZEblbaHdiM5uLkozyef5SnSB6RzZskmhECdsfqm.Bt9afC0IK', '2024-07-11 17:43:10', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1044, 1082, 'Bipin', 'Patel', 'Bankstreetmilano@gmail.com',
    '$2y$10$uX6NPUuQMV7zCj4kP9viGeOWh/bFBw.ub/qb..CBx0EK/YVEuLev6', '2024-08-28 17:23:05', 1, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1046, 1087, 'Mohsmmed ', 'Amer', 'CALLAMER@GMAIL.COM',
    '$2y$10$.eB5YlsND4NtgJ2TLYOdeOZQZWaqTRvdgo/X2jGk2TyEP9WOIxydC', '2024-08-07 15:06:42', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1047, 1083, 'Bipinchandra ', 'Patel', 'Krunalptl01101999@gmail.com ',
    '$2y$10$U/rKU9Si63q2PiKQHeKDCuMmH57viDZtQiFZ1EBCgXdE8NkHeTTri', '2025-03-15 02:42:07', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1048, 323, 'Shane', '   ', 'charmthaicuisineottawa@gmail.com',
    '$2y$10$T6hfjyxI6uC/EnIPHTLmCOizCnuv8/yUGbats8Bo/PYg864yl.Dfy', '2024-09-03 18:50:18', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1049, 1088, 'Mahde', 'Ghandour', 'mahde_ghandour@hotmail.com',
    '$2y$10$/HPZ.TTIsOQdKum3jJcL0.DRyDrn545tmug8qGUZSfrbC2dvX1Qsu', '2024-09-16 16:11:19', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1050, 0, 'Mahde', 'Ghandour', 'Allout613@alloutburger.com',
    '$2y$10$uCLTDy/SXvrXXVOeD4tuX.F6/ETRJJY9Kv.4G9a1IbSy/Zv/kQQJO', '2025-04-28 21:25:04', 24, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1053, 657, 'Zhang ', 'Honghao', 'thai.coconut.ottawa@outlook.com',
    '$2y$10$osCLu2boJQfGoU.kB1wk8.4b7ZX9yEKgr.hSgnWFhHOsTrG11SAj.', '2025-01-03 01:25:34', 8, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1055, 1093, 'test2', 'test2', 'alexandra.nicolae000@gmail.com',
    '$2y$10$KJL9VIZppPnT9erQLR09QegCUzGgqXOo714oRMFiupuuz2rBvt3pu', '2024-11-21 17:39:06', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1056, 1092, 'Mitulkumar ', 'Kakani', 'mykonosgreekgrillz@gmail.com',
    '$2y$12$DSlpVLNMFnp4czF3YZAIu.69lo7xofFEDbtbUdaCZjKTArdTzcUIq', '2025-09-10 23:17:38', 6, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1057, 1093, 'Mitulkumar ', 'Kakani', 'mitulkakani1996@gmail.com',
    '$2y$12$wlH.WCno2fwlAhwH6Ap1Xef.DyQzsv1OiXSDif6SRr1Cx66mDGgpy', '2025-08-13 03:31:14', 46, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1058, 213, 'Mitulkumar ', 'Kakani', 'kemptvillemilanopizza@gmail.com',
    '$2y$12$.glkz1/gITxnr4tkSyv/B.whN2JlQU2Htux3h7shejPVVVY8t9orC', '2025-09-02 13:21:52', 53, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1059, 1094, ' Inkyung ', 'Cho', 'sushiyanagatineau@gmail.com',
    '$2y$10$yA2f6rZsmGoZCabmMp./Q.eBSHPfqgaupbsH7noWbBGG36Nsq5suO', '2024-12-19 19:32:21', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1061, 257, 'Riverside', 'Pizza', 'riversidepizzeria8@gmail.com',
    '$2y$10$0TTwEfs91KMF93yDzjEDZOIEWT0WH9ln3HxkNEzvKJt.OmpgjoHVW', '2025-04-12 03:06:35', 3, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1062, 1089, 'Milano', 'Prescott', 'milanopizzaprescott@gmail.com',
    '$2y$12$oz4cqiKSqtFrlQ9dgGPj3Oque3nlIY4BX6wO1rZstSbn7Gs6YpMRG', '2025-09-12 00:57:52', 264, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1063, 983, 'Charbel', '  ', 'cnakhle80@gmail.com',
    '$2y$10$FrrPwZT/1on11qPLjMs1ieS82d0P9tymXiXQc3XfL3njg7mamGrtu', '2025-02-13 16:14:29', 2, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1064, 790, 'Marwan ', 'Chwah', 'marwanchwah@hotmail.com',
    '$2y$10$gnvAK5C/tzI4WsKH5x0BQOR546kV1pyVNXdT7rDFgS5OntR1rjpBW', '2025-03-11 18:01:11', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1065, 818, ' tran ', 'manh tuan vu', 'vutranmanhtuan@gmail.com',
    '$2y$10$DZJmacOzjgrRqqeQlDUfQu2v1qBXxcm5JEQRdshkFaia5t98tWDui', '2025-03-24 14:58:34', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1067, 914, 'Nabeel ', 'Ayasrah', 'Ayasrah69@hotmail.com',
    '$2y$10$87/8O24ewwhEvwxaJJ9oNOxfzjed4zLqVVtJelb323/7u4q.ebiRG', '2025-04-09 18:25:04', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1069, 157, 'Rajveer ', 'Singhoberoi ', 'Hopizza9@gmail.com ',
    '$2y$10$TuGOnx3k9Gd0nDhYmaSH/e2Lk.i7skHHgwOjzZcR9RACkogC9B4Wa', '2025-04-15 12:56:28', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1070, 716, 'Kaiqi ', 'Shi ', 'shi00063@algonquinlive.com',
    '$2y$10$6cOS92NYehsrkUiB/RfzTOc0xx1XGGlgvBoAC4DXbl9.rvB4qUPV.', '2025-07-20 21:17:24', 4, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1071, 0, 'Jordan', 'James', 'jordan@worklocal.ca',
    '$2y$10$5OmFXsG2B/D.1g0Ml0Fklu6m8TyPyV2/ovWZbDyViVk4Lc6C.B1b6', '2025-06-16 19:30:01', 0, '0', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1072, 817, 'Karim ', 'Jalili', 'supremepizzadonald@gmail.com',
    '$2y$10$Jrs5oLm0xVHCnFHDjhrMbe9GyQ8h7jSQMlZulvKToYzO9iBc/tLKm', '2025-07-09 16:57:13', 2, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1073, 1060, 'Joseph', 'Nicolas', 'josephnicolas@live.ca',
    '$2y$10$6kAjjutgdwoU1gJMvKx6q.1XZr7FlO40Es5gLMABawVdpohQd1XMS', '2025-08-04 15:57:44', 0, '1', 'n',
    NULL, NULL
);
INSERT INTO staging.v1_restaurant_admin_users (
    legacy_admin_id, legacy_v1_restaurant_id, fname, lname, email,
    password_hash, lastlogin, login_count, active_user, send_statement,
    created_at, updated_at
) VALUES (
    1074, 114, 'brian', 'james', 'brian@worklocal.ca',
    '$2y$10$d5edc.i0ChshbtTiKcmgA.AjeGdHMGJO1qkU73cQ3rUvwPPUuvOMu', '2025-08-13 14:39:09', 0, '1', 'n',
    NULL, NULL
);

COMMIT;

-- Verification
SELECT COUNT(*) FROM staging.v1_restaurant_admin_users;
SELECT COUNT(*) FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id > 0;
SELECT COUNT(*) FROM staging.v1_restaurant_admin_users WHERE legacy_v1_restaurant_id = 0;