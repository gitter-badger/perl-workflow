CREATE TABLE ticket (
  ticket_id    varchar(8) not null,
  subject      varchar(50) not null,
  description  text null,
  creator      varchar(30) not null,
  status       varchar(30) null,
  due_date     date null,
  last_update  datetime not null,
  primary key( ticket_id )
);

CREATE TABLE workflow_ticket (
  workflow_id  int not null,
  ticket_id    varchar(8) not null,
  primary key ( workflow_id )
);