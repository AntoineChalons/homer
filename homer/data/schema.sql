PRAGMA foreign_keys = ON;

BEGIN;

DROP TABLE IF EXISTS interactions;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS currencies;

CREATE TABLE countries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE currencies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE cities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  postcode TEXT NOT NULL,
  country_id INTEGER NOT NULL,

  FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE,

  UNIQUE (country_id, postcode, name)
);


CREATE TABLE companies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  industry TEXT,
  city_id INTEGER,
  website TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL
);

CREATE TABLE contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  company_id INTEGER,
  first_name TEXT NOT NULL,
  last_name TEXT,
  email TEXT UNIQUE,
  phone TEXT,
  position TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
);

CREATE TABLE positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  company_id INTEGER NOT NULL,
  primary_contact_id INTEGER,
  name TEXT NOT NULL,
  business_unit TEXT NOT NULL,
  reference TEXT,
  job_description_link TEXT,
  interest REAL NOT NULL DEFAULT 50 CHECK (interest BETWEEN 0 AND 100),
  probability REAL NOT NULL DEFAULT 50 CHECK (probability BETWEEN 0 AND 100),
  status TEXT NOT NULL DEFAULT 'applied'
    CHECK (status IN ('draft','applied','interview','offer','rejected','withdrawn')),
  weekly_hours REAL NOT NULL DEFAULT 40,
  fixed_duration INTEGER NOT NULL DEFAULT 0 CHECK (fixed_duration IN (0, 1)),
  year_salary REAL NOT NULL CHECK (year_salary >= 0),
  salary_currency_id INTEGER,
  expected_close_date TEXT,
  expected_start_date TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  FOREIGN KEY (primary_contact_id) REFERENCES contacts(id),
  FOREIGN KEY (salary_currency_id) REFERENCES currencies(id) ON DELETE SET NULL
);

CREATE TABLE interactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contact_id INTEGER NOT NULL,
  type TEXT NOT NULL DEFAULT 'meeting'
    CHECK (type IN ('phone','email','chat','interview','post','hear-say')),
  notes TEXT,
  interaction_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
);

CREATE INDEX idx_contacts_company_id ON contacts(company_id);
CREATE INDEX idx_positions_company_id ON positions(company_id);
CREATE INDEX idx_positions_primary_contact_id ON positions(primary_contact_id);
CREATE INDEX idx_interactions_contact_id ON interactions(contact_id);

COMMIT;
