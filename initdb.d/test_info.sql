-- 1. 会社情報テーブル
CREATE TABLE 会社情報 (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('internal', 'client') NOT NULL,
    会社名 VARCHAR(100) NOT NULL,
    法人格 VARCHAR(50),
    法人格前後 ENUM('前', '後') DEFAULT '前',
    拠点名 VARCHAR(100),
    郵便番号 VARCHAR(10),
    住所 VARCHAR(255),
    電話番号 VARCHAR(20),
    FAX番号 VARCHAR(20),
    WEBサイト VARCHAR(255),
    メールアドレス VARCHAR(255),
    自社担当者 INT,
    取引先分類 VARCHAR(100),
    締め日 TINYINT UNSIGNED,
    払い月 TINYINT UNSIGNED,
    払い日 TINYINT UNSIGNED,
    現金払い額 BIGINT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. ユーザー情報テーブル
CREATE TABLE ユーザー情報 (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    role ENUM('admin', 'client_user', 'internal_user') NOT NULL,
    氏名 VARCHAR(100) NOT NULL,
    ふりがな VARCHAR(100),
    役職 VARCHAR(100),
    ログインネーム VARCHAR(50) NOT NULL UNIQUE,
    所属課 VARCHAR(100),
    部門 VARCHAR(100),
    入社日 DATE,
    メールアドレス VARCHAR(100) NOT NULL UNIQUE,
    登録日 DATETIME DEFAULT CURRENT_TIMESTAMP,
    更新日 DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES 会社情報(company_id)
);

-- 3. 会社情報データ
INSERT INTO 会社情報 (
    type, 会社名, 法人格, 法人格前後, 拠点名, 郵便番号, 住所, 電話番号, FAX番号,
    WEBサイト, メールアドレス, 自社担当者, 取引先分類, 締め日, 払い月, 払い日, 現金払い額
) VALUES
('client', 'セリュノアテクノロジーズ', '株式会社', '前', '東京本社', '100-0001', '東京都千代田区千代田1-1', '03-1234-5678', '03-1234-5679', 'https://www.celynoa-tech.co.jp', 'info@celynoa-tech.co.jp', NULL, '一次請け', 31, 1, 15, 1000000),
('internal', 'ノアシステムズ', '合同会社', '後', '大阪営業所', '530-0001', '大阪府大阪市北区梅田1-1-1', '06-2345-6789', '06-2345-6790', 'http://www.noa-systems.jp', 'contact@noa-systems.jp', NULL, 'グループ会社', 25, 2, 10, 0),
('client', 'アストリア工業', '株式会社', '前', '名古屋支店', '460-0008', '愛知県名古屋市中区錦2-10-1', '052-1111-2222', '052-1111-3333', 'https://www.astoria-ind.co.jp', 'support@astoria.co.jp', NULL, '二次請け', 20, 2, 5, 300000),
('internal', 'ブルークラフト', '合同会社', '後', '福岡本社', '810-0001', '福岡県福岡市中央区天神1-1-1', '092-3333-4444', '092-3333-5555', 'http://www.bluecraft.jp', 'info@bluecraft.jp', NULL, 'グループ会社', 15, 3, 20, 50000);

-- 4. ユーザー情報データ
INSERT INTO ユーザー情報 (
    company_id, role, 氏名, ふりがな, 役職, ログインネーム, 所属課, 部門, 入社日, メールアドレス
) VALUES
(1, 'admin', '田中 太郎', 'たなか たろう', '部長', 'tanaka', '営業課', '営業部', '2020-04-01', 'tanaka@example.com'),
(1, 'client_user', '佐藤 花子', 'さとう はなこ', '主任', 'sato', '開発課', '開発部', '2021-06-15', 'sato@example.com'),
(3, 'client_user', '山本 一郎', 'やまもと いちろう', '係長', 'yamamoto', '管理課', '総務部', '2019-08-10', 'yamamoto@astoria.co.jp'),
(4, 'internal_user', '伊藤 美咲', 'いとう みさき', '課長', 'ito', '営業課', '営業部', '2018-01-05', 'ito@bluecraft.jp');

-- 5. 外部キー（自社担当者）追加
ALTER TABLE 会社情報
ADD CONSTRAINT fk_自社担当者
FOREIGN KEY (自社担当者) REFERENCES ユーザー情報(user_id);

-- 6. 型枠情報テーブル
CREATE TABLE 型枠情報 (
    formwork_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    拠点名 VARCHAR(100),
    型枠品名 VARCHAR(100),
    サイズ・寸法 VARCHAR(100),
    取個数 INT,
    型枠仕様目的 TEXT,
    製品施工状態 VARCHAR(100),
    発注形態 VARCHAR(100),
    設計既存有無 TINYINT(1),
    重点実施事項 TEXT,
    概算納期 DATE,
    製造番号 VARCHAR(100),
    製造年月日 DATE,
    数量 INT,
    購入単価 DECIMAL(10,2),
    仕様ボルト VARCHAR(100),
    剥離剤タイプ VARCHAR(100),
    型枠製造元 VARCHAR(100),
    QRコード VARCHAR(255),
    顧客担当者 INT NOT NULL,
    自社営業担当者 INT NOT NULL,
    FOREIGN KEY (company_id) REFERENCES 会社情報(company_id),
    FOREIGN KEY (顧客担当者) REFERENCES ユーザー情報(user_id),
    FOREIGN KEY (自社営業担当者) REFERENCES ユーザー情報(user_id)
);

-- 7. 型枠情報データ
INSERT INTO 型枠情報 (
    company_id, 拠点名, 型枠品名, サイズ・寸法, 取個数, 型枠仕様目的, 製品施工状態,
    発注形態, 設計既存有無, 重点実施事項, 概算納期, 製造番号, 製造年月日,
    数量, 購入単価, 仕様ボルト, 剥離剤タイプ, 型枠製造元, QRコード,
    顧客担当者, 自社営業担当者
) VALUES
(1, '東京支店1', '型枠A1', '100x200x300', 5, '住宅基礎', '未施工', '一括', 1, '耐久性重視', '2025-06-21', 'FW001', '2025-02-21', 10, 15000.00, 'M10', 'シリコン系', '日本型枠製作所', 'QR001', 1, 2),
(1, '東京支店2', '型枠A2', '100x200x300', 5, '住宅基礎', '未施工', '一括', 1, '耐久性重視', '2025-06-21', 'FW002', '2025-02-21', 10, 15000.00, 'M10', 'シリコン系', '日本型枠製作所', 'QR002', 1, 2),
(3, '名古屋工場', '型枠B1', '150x250x300', 3, 'マンション基礎', '施工中', '分納', 0, 'コスト重視', '2025-07-10', 'FW003', '2025-03-15', 7, 12000.00, 'M8', 'ワックス系', '東海鋼材', 'QR003', 3, 4),
(4, '福岡工場', '型枠C1', '200x300x400', 2, '倉庫基礎', '完了', '都度', 1, '強度優先', '2025-08-01', 'FW004', '2025-01-20', 4, 18000.00, 'M12', '油系', '九州型枠株式会社', 'QR004', 3, 4);

-- 8. 取引評価
CREATE TABLE 取引評価 (
    trade_evaluation_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    formwork_id INT NOT NULL,
    顧客担当者 INT NOT NULL,
    FOREIGN KEY (company_id) REFERENCES 会社情報(company_id),
    FOREIGN KEY (formwork_id) REFERENCES 型枠情報(formwork_id),
    FOREIGN KEY (顧客担当者) REFERENCES ユーザー情報(user_id)
);

INSERT INTO 取引評価 (company_id, formwork_id, 顧客担当者) VALUES
(1, 1, 1),
(3, 3, 3),
(4, 4, 3);

-- 9. 付属部品
CREATE TABLE 付属部品 (
    accessories_id INT PRIMARY KEY AUTO_INCREMENT,
    formwork_id INT NOT NULL,
    部品品種 VARCHAR(100),
    部品名 VARCHAR(100),
    部品サイズ・寸法 VARCHAR(100),
    部品数量 INT,
    FOREIGN KEY (formwork_id) REFERENCES 型枠情報(formwork_id)
);

INSERT INTO 付属部品 (formwork_id, 部品品種, 部品名, 部品サイズ・寸法, 部品数量) VALUES
(1, 'ボルト', 'アンカーボルト', 'M10x100', 20),
(2, 'ボルト', 'アンカーボルト', 'M10x100', 20),
(3, 'ナット', '六角ナット', 'M8', 30),
(4, 'ワッシャー', 'スプリングワッシャー', 'M12', 25);

-- 10. 図面データ
CREATE TABLE 図面データ (
    drawing_id INT PRIMARY KEY AUTO_INCREMENT,
    書類名称 VARCHAR(255) NOT NULL,
    製造番号 VARCHAR(100),
    図面データ LONGBLOB
);

INSERT INTO 図面データ (書類名称, 製造番号, 図面データ) VALUES
('型枠図面1', 'FW001', NULL),
('型枠図面2', 'FW002', NULL),
('型枠図面3', 'FW003', NULL),
('型枠図面4', 'FW004', NULL);

-- 11. 型枠画像
CREATE TABLE 型枠画像 (
    formwork_image_id INT PRIMARY KEY AUTO_INCREMENT,
    formwork_id INT NOT NULL,
    image_URL VARCHAR(255) NOT NULL,
    FOREIGN KEY (formwork_id) REFERENCES 型枠情報(formwork_id)
);

INSERT INTO 型枠画像 (formwork_id, image_URL) VALUES
(1, 'https://example.com/images/formwork1.jpg'),
(2, 'https://example.com/images/formwork2.jpg'),
(3, 'https://example.com/images/formwork3.jpg'),
(4, 'https://example.com/images/formwork4.jpg');

-- 12. 型枠動画
CREATE TABLE 型枠動画 (
    formwork_video_id INT PRIMARY KEY AUTO_INCREMENT,
    formwork_id INT NOT NULL,
    video_URL VARCHAR(255) NOT NULL,
    FOREIGN KEY (formwork_id) REFERENCES 型枠情報(formwork_id)
);

INSERT INTO 型枠動画 (formwork_id, video_URL) VALUES
(1, 'https://example.com/videos/formwork1.mp4'),
(2, 'https://example.com/videos/formwork2.mp4'),
(3, 'https://example.com/videos/formwork3.mp4'),
(4, 'https://example.com/videos/formwork4.mp4');
