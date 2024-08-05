unit Classe.Pedido;

interface

uses
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  REST.Json.Types;

{$M+}

type
  TItens = class(TPersistent)
  private
    FCodigo: Integer;
    [JSONName('codigo_ped')]
    FCodigoPed: Integer;
    [JSONName('codigo_prod')]
    FCodigoProd: Integer;
    [JSONName('descricao')]
    FDescricao: String;
    [JSONName('qtd_produto')]
    FQtdProduto: Integer;
    [JSONName('val_produto')]
    FValProduto: Double;
    [JSONName('val_total')]
    FValTotal: Double;
  published
    property Codigo: Integer read FCodigo write FCodigo;
    property CodigoPed: Integer read FCodigoPed write FCodigoPed;
    property CodigoProd: Integer read FCodigoProd write FCodigoProd;
    property Descricao: String read FDescricao write FDescricao;
    property QtdProduto: Integer read FQtdProduto write FQtdProduto;
    property ValProduto: Double read FValProduto write FValProduto;
    property ValTotal: Double read FValTotal write FValTotal;
  end;

  IPedido = interface
  ['{09339C60-4A8C-4F1E-9143-2C2B61892001}']
    function getCidade: string;
    function getCodigo: Integer;
    function getCodigoCli: Integer;
    function getDatPedido: string;
    function getItens: TArray<TItens>;
    function getNome: string;
    function getUf: string;
    function getValPedido: Double;

    procedure setCidade(const Value: string);
    procedure setCodigo(const Value: Integer);
    procedure setCodigoCli(const Value: Integer);
    procedure setDatPedido(const Value: string);
    procedure setItens(const Value: TArray<TItens>);
    procedure setNome(const Value: string);
    procedure setUf(const Value: string);
    procedure setValPedido(const Value: Double);

    property Cidade: string read getCidade write setCidade;
    property Codigo: Integer read getCodigo write setCodigo;
    property CodigoCli: Integer read getCodigoCli write setCodigoCli;
    property DatPedido: string read getDatPedido write setDatPedido;
    property Nome: string read getNome write setNome;
    property Uf: string read getUf write setUf;
    property ValPedido: Double read getValPedido write setValPedido;
    property Itens: TArray<TItens> read getItens write setItens;
  end;

  TPedido = class(TInterfacedObject, IPedido)
  private
    FCidade: string;
    FCodigo: Integer;
    [JSONName('codigo_cli')]
    FCodigoCli: Integer;
    [JSONName('dat_pedido')]
    FDatPedido: string;
    [JSONName('itens'), JSONMarshalled(False)]
    FItens: TArray<TItens>;
    FNome: string;
    FUf: string;
    [JSONName('val_pedido')]
    FValPedido: Double;
    function getCidade: string;
    function getCodigo: Integer;
    function getCodigoCli: Integer;
    function getDatPedido: string;
    function getItens: TArray<TItens>;
    function getNome: string;
    function getUf: string;
    function getValPedido: Double;
    procedure setCidade(const Value: string);
    procedure setCodigo(const Value: Integer);
    procedure setCodigoCli(const Value: Integer);
    procedure setDatPedido(const Value: string);
    procedure setItens(const Value: TArray<TItens>);
    procedure setNome(const Value: string);
    procedure setUf(const Value: string);
    procedure setValPedido(const Value: Double);
  published
    property Cidade: string read getCidade write setCidade;
    property Codigo: Integer read getCodigo write setCodigo;
    property CodigoCli: Integer read getCodigoCli write setCodigoCli;
    property DatPedido: string read getDatPedido write setDatPedido;
    property Nome: string read getNome write setNome;
    property Uf: string read getUf write setUf;
    property ValPedido: Double read getValPedido write setValPedido;
    property Itens: TArray<TItens> read getItens write setItens;
  public
    destructor Destroy; override;
  end;

implementation

{ TPedido }

destructor TPedido.Destroy;
begin
  inherited;
end;

{ TClassBase }

function TPedido.getCidade: string;
begin
  Result := FCidade;
end;

function TPedido.getCodigo: Integer;
begin
  Result := FCodigo;
end;

function TPedido.getCodigoCli: Integer;
begin
  Result := FCodigoCli;
end;

function TPedido.getDatPedido: string;
begin
  Result := FDatPedido;
end;

function TPedido.getItens: TArray<TItens>;
begin
  Result := FItens;
end;

function TPedido.getNome: string;
begin
  Result := FNome;
end;

function TPedido.getUf: string;
begin
  Result := FUf;
end;

function TPedido.getValPedido: Double;
begin
  Result := FValPedido;
end;

procedure TPedido.setCidade(const Value: string);
begin
  FCidade := Value;
end;

procedure TPedido.setCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TPedido.setCodigoCli(const Value: Integer);
begin
  FCodigoCli := Value;
end;

procedure TPedido.setDatPedido(const Value: string);
begin
  FDatPedido := Value;
end;

procedure TPedido.setItens(const Value: TArray<TItens>);
begin
  FItens := Value;
end;

procedure TPedido.setNome(const Value: string);
begin
  FNome := Value;
end;

procedure TPedido.setUf(const Value: string);
begin
  FUf := Value;
end;

procedure TPedido.setValPedido(const Value: Double);
begin
  FValPedido := Value;
end;

end.
