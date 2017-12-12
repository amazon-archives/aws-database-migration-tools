Create Schema Stock;


Create Table Stock.Ticker
(
  ticker_symbol varchar(20) not null,
  sector varchar(20) not null,
  change float not null,
  price float not null
);
