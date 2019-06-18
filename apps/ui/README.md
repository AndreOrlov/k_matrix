# Ui

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix


Команды SPI для матрицы 4 х (8 х 8)
{:ok, ref} = Circuits.SPI.open("spidev0.0") 
:ok = Circuits.SPI.close(ref)  

{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x0C, 0x00, 0x0C, 0x00, 0x0C, 0x00, 0x0C, 0x00 >>) # shutdown
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x0C, 0x01, 0x0C, 0x01, 0x0C, 0x01, 0x0C, 0x01 >>) # turn on
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x0F, 0x01, 0x0F, 0x01, 0x0F, 0x01, 0x0F, 0x01 >>) # включить все
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x0F, 0x00, 0x0F, 0x00, 0x0F, 0x00, 0x0F, 0x00 >>) # выключить все
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x09, 0x00, 0x09, 0x00, 0x09, 0x00, 0x09, 0x00 >>) # no decode mode select
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x0B, 0x07, 0x0B, 0x07, 0x0B, 0x07, 0x0B, 0x07 >>) # активировать 8 строк
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x02, 0xFF, 0x02, 0xFF, 0x02, 0xFF, 0x02, 0xFF >>) # включить 8 колонок 2й строки
{:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>} = Circuits.SPI.transfer(ref, <<0x02, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x00 >>) # выключить 8 колонок 2й строки

или Circuits.SPI.transfer может вернуть
{:error, :transfer_failed}
