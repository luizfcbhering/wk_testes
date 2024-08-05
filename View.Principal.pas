unit View.Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.JSON,
  System.Rtti,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.DBCtrls,

  Data.DB,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Rest.Json,

  Classe.Pedido;

type
  TfPrincipal = class(TForm)
    grdProdutos: TDBGrid;
    pnlCabecalho: TPanel;
    pnlRodape: TPanel;
    pnlDados: TPanel;
    lblCliente: TLabel;
    edtCodigoCli: TEdit;
    edtNome: TEdit;
    lblProduto: TLabel;
    mtPedidos: TFDMemTable;
    mtItensPedidos: TFDMemTable;
    dsPedidos: TDataSource;
    dsItensPedidos: TDataSource;
    btnGravarItem: TBitBtn;
    mtItensPedidoscodigo: TFDAutoIncField;
    mtItensPedidoscodigo_ped: TIntegerField;
    mtItensPedidoscodigo_prod: TIntegerField;
    mtItensPedidosqtd_produto: TIntegerField;
    mtItensPedidosval_produto: TFMTBCDField;
    mtItensPedidosval_total: TFMTBCDField;
    mtItensPedidosdescricao: TStringField;
    mtPedidoscodigo: TIntegerField;
    mtPedidoscodigo_cli: TIntegerField;
    mtPedidosdat_pedido: TDateField;
    mtPedidosval_pedido: TFMTBCDField;
    mtPedidosnome: TStringField;
    mtPedidoscidade: TStringField;
    mtPedidosuf: TStringField;
    edtCodigoProd: TEdit;
    edtDescricao: TEdit;
    edtQtdProduto: TEdit;
    edtValProduto: TEdit;
    edtValTotal: TEdit;
    lblQtd: TLabel;
    lblValUnitario: TLabel;
    lblValTotal: TLabel;
    btnSair: TBitBtn;
    btnGravarPedido: TBitBtn;
    btnPesquisar: TBitBtn;
    btnCancelar: TBitBtn;
    pnlTotal: TPanel;
    lblTotalPedido: TLabel;
    edtValPedido: TEdit;
    procedure edtCodigoCliKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCodigoCliChange(Sender: TObject);
    procedure edtNomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grdProdutosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCodigoProdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtQtdProdutoExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtQtdProdutoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnGravarItemClick(Sender: TObject);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure grdProdutosDblClick(Sender: TObject);
  private
    { Private declarations }
    FPedido: IPedido;
    procedure PreencherPedido(Pedido:IPedido);
    procedure PesquisarProduto;
    procedure PesquisarCliente(ACampo: String);

    procedure GravarPedido;
    procedure GravarItens;

    procedure LimparItens;
    procedure LimparClasse(Pedido: IPedido);
    procedure EditarItem;
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.dfm}

uses
  Model.Pesquisa,
  Model.Dados;

procedure TfPrincipal.btnGravarPedidoClick(Sender: TObject);
begin
  ModelDados.InserirPedido(ModelDados.GerarJSONPedido(mtPedidos, mtItensPedidos));

  mtPedidos.EmptyDataSet;
  mtItensPedidos.EmptyDataSet;

  edtCodigoCli.Clear;
  edtNome.Clear;
  edtCodigoCli.SetFocus;
  lblTotalPedido.Caption := 'Total: R$ 0,00';
end;

procedure TfPrincipal.btnPesquisarClick(Sender: TObject);
var
  Pedido: String;
begin
  if InputQuery('Localizar Pedido', 'Nº Pedido', Pedido) then
  begin
    if StrToIntDef(Pedido, 0) > 0 then
    begin
      edtCodigoCli.Clear;
      edtNome.Clear;

      mtPedidos.EmptyDataSet;
      mtItensPedidos.EmptyDataSet;

      ModelDados.qryPedidos.Close;
      ModelDados.qryPedidos.ParamByName('codigo').AsInteger := StrToInt(Pedido);
      ModelDados.qryPedidos.Open;

      ModelDados.qryItensPedido.Close;
      ModelDados.qryItensPedido.ParamByName('codigo_ped').AsInteger := StrToInt(Pedido);
      ModelDados.qryItensPedido.Open;

      if ModelDados.qryPedidos.IsEmpty then
      begin
        ShowMessage('Pedido não localizado!');
        Exit;
      end;

      if mtPedidos.Active then
      begin
        mtPedidos.Active := False;
        mtItensPedidos.Active := False;
      end;

      mtPedidos.Data      := ModelDados.qryPedidos.Data;
      mtItensPedidos.Data := ModelDados.qryItensPedido.Data;

      // Exemplo de serialização/deserialização de classes
      FPedido := TJson.JsonToObject<TPedido>(ModelDados.GerarJSONPedido(mtPedidos, mtItensPedidos));
      PreencherPedido(FPedido);

      pnlDados.Enabled := True;
      edtCodigoProd.SetFocus;
    end;

  end;
end;

procedure TfPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfPrincipal.btnCancelarClick(Sender: TObject);
var
  Pedido: String;
begin
  if InputQuery('Cancelar Pedido', 'Nº Pedido', Pedido) then
  begin
    if StrToIntDef(Pedido, 0) > 0 then
    begin
      edtCodigoCli.Clear;
      edtNome.Clear;

      mtPedidos.EmptyDataSet;
      mtItensPedidos.EmptyDataSet;

      ModelDados.qryPedidos.Close;
      ModelDados.qryPedidos.ParamByName('codigo').AsInteger := StrToInt(Pedido);
      ModelDados.qryPedidos.Open;

      if ModelDados.qryPedidos.IsEmpty then
      begin
        ShowMessage('Pedido não localizado!');
        Exit;
      end;

      if mtPedidos.Active then
      begin
        mtPedidos.Active := False;
        mtItensPedidos.Active := False;
      end;

      try
        ModelDados.qryPedidos.Delete;
        ShowMessage('Pedido excluído com sucesso !');
      except
        on E: Exception do
          ShowMessage('Erro ao excluir o pedido. Favor chamar o suporte. '+E.Message);
      end;

      pnlDados.Enabled := False;
      edtCodigoCli.SetFocus;
    end;
  end;
end;

procedure TfPrincipal.btnGravarItemClick(Sender: TObject);
begin
  GravarItens;
end;

procedure TfPrincipal.edtCodigoCliChange(Sender: TObject);
begin
  if (Trim(edtCodigoCli.Text) = '') then
    edtNome.Clear;
end;

procedure TfPrincipal.edtCodigoCliKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F3) or (Key = VK_RETURN) then
  begin
    PesquisarCliente('codigo');
  end
  else
  if Key = VK_F4 then
  begin
    edtCodigoCli.Clear;
    edtNome.Clear;
    pnlDados.Enabled := False;
  end;
end;

procedure TfPrincipal.edtCodigoProdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F3) or (Key = VK_RETURN) then
  begin
    PesquisarProduto;
  end
  else
  if Key = VK_F4 then
  begin
    LimparItens;
  end;
end;

procedure TfPrincipal.edtNomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F3) or (Key = VK_RETURN) then
  begin
    PesquisarCliente('nome');
  end
  else
  if Key = VK_F4 then
  begin
    edtCodigoCli.Clear;
    edtNome.Clear;
    pnlDados.Enabled := False;
  end;
end;

procedure TfPrincipal.edtQtdProdutoExit(Sender: TObject);
begin
  edtValTotal.Text := FormatCurr('0.00', StrToCurrDef(edtValProduto.Text,0) * StrToIntDef(edtQtdProduto.Text, 1));
end;

procedure TfPrincipal.edtQtdProdutoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
  begin
    edtValTotal.Text := FormatCurr('0.00', StrToCurr(edtValProduto.Text) * StrToIntDef(edtQtdProduto.Text, 1));
    btnGravarItem.SetFocus;
  end;
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
  FPedido := TPedido.Create;
  mtPedidos.CreateDataSet;
  mtItensPedidos.CreateDataSet;
end;

procedure TfPrincipal.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F6 then
    btnGravarPedidoClick(Sender)
  else
  if Key = VK_F7 then
    btnPesquisarClick(Sender)
  else
  if Key = VK_F8 then
    btnCancelarClick(Sender);
end;

procedure TfPrincipal.GravarItens;
begin
  mtItensPedidoscodigo_prod.AsString    := edtCodigoProd.Text;
  mtItensPedidosdescricao.AsString      := edtDescricao.Text;
  mtItensPedidosqtd_produto.AsInteger   := StrToIntDef(edtQtdProduto.Text, 0);
  mtItensPedidosval_produto.AsCurrency  := StrToCurr(edtValProduto.Text);
  mtItensPedidosval_total.AsCurrency    := StrToCurr(edtValTotal.Text);
  mtItensPedidos.Post;

  mtPedidos.Edit;
  mtPedidosval_pedido.AsCurrency :=  mtPedidosval_pedido.AsCurrency + mtItensPedidosval_total.AsCurrency;
  mtPedidos.Post;

  edtValPedido.Text := FormatCurr(',#0.00', mtPedidosval_pedido.AsCurrency);

  LimparItens;
  LimparClasse(FPedido);
end;

procedure TfPrincipal.GravarPedido;
begin
  mtPedidos.Append;
  mtPedidoscodigo.AsInteger      := 0;
  mtPedidoscodigo_cli.AsInteger  := FPedido.CodigoCli;
  mtPedidosdat_pedido.AsDateTime := Date;
  mtPedidosnome.AsString         := FPedido.Nome;
  mtPedidoscidade.AsString       := FPedido.Cidade;
  mtPedidosuf.AsString           := FPedido.Uf;
  mtPedidos.Post;
end;

procedure TfPrincipal.grdProdutosDblClick(Sender: TObject);
begin
  EditarItem;
end;

procedure TfPrincipal.grdProdutosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ConfExclusao : Integer;
begin
  try
    if Key = VK_DELETE then
    begin
      ConfExclusao := Application.MessageBox('Confirma a exclusão deste produto?', 'Atenção', MB_YesNo+mb_DefButton2+mb_IconQuestion);
      if ConfExclusao = IDYes then
        mtItensPedidos.Delete;
    end
    else
    if Key = VK_RETURN then
      EditarItem;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfPrincipal.LimparClasse(Pedido: IPedido);
var
  Context   : TRttiContext;
  TypObj    : TRttiType;
  Prop      : TRttiProperty;
begin
  Context   := TRttiContext.Create;
  TypObj    := Context.GetType(TObject(Pedido).ClassInfo);
  try
    for Prop in TypObj.GetProperties do
    begin
      if (Prop.GetValue(TObject(Pedido)).Kind = tkFloat) or (Prop.GetValue(TObject(Pedido)).Kind = tkInteger) then
        Prop.SetValue(TObject(Pedido), 0)
      else if (Prop.GetValue(TObject(Pedido)).Kind in [tkString, tkUString, tkWideString]) then
        Prop.SetValue(TObject(Pedido), '')
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfPrincipal.LimparItens;
begin
  edtCodigoProd.Clear;
  edtDescricao.Clear;
  edtQtdProduto.Clear;
  edtValProduto.Clear;
  edtValTotal.Clear;

  edtCodigoProd.SetFocus;
end;

procedure TfPrincipal.EditarItem;
begin
  begin
    mtItensPedidos.Edit;
    edtCodigoProd.Text  := mtItensPedidoscodigo_prod.AsString;
    edtDescricao.Text   := mtItensPedidosdescricao.AsString;
    edtQtdProduto.Text  := mtItensPedidosqtd_produto.AsString;
    edtValProduto.Text  := FormatCurr('0.00', mtItensPedidosval_produto.AsCurrency);
    edtValTotal.Text    := FormatCurr('0.00', mtItensPedidosval_total.AsCurrency);
    edtQtdProduto.SetFocus;
  end;
end;

procedure TfPrincipal.PesquisarCliente(ACampo: String);
begin
  try
    if (ModelPesquisa.PesquisarCliente(ACampo, ACampo, edtCodigoCli.Text, 'ViewClientes')) then
    begin
       FPedido.CodigoCli := ModelPesquisa.qryPessoascodigo.AsInteger;
       FPedido.Nome      := ModelPesquisa.qryPessoasnome.AsString;
       FPedido.Cidade    := ModelPesquisa.qryPessoascidade.AsString;
       FPedido.Uf        := ModelPesquisa.qryPessoasuf.AsString;

       edtCodigoCli.Text := ModelPesquisa.qryPessoascodigo.AsString;
       edtNome.Text      := ModelPesquisa.qryPessoasnome.AsString;
       pnlDados.Enabled  := True;

       edtCodigoProd.SetFocus;

       GravarPedido;
    end
    else
    begin
      ShowMessage('Cliente não localizado !!!!');
      edtCodigoCli.Clear;
      edtNome.Clear;

      edtCodigoCli.SetFocus;

      pnlDados.Enabled := False;
    end;
  finally
    ModelPesquisa.qryPessoas.Close;
    ModelPesquisa.qryPessoas.SQL.Text := ModelPesquisa.gSQLOri;
  end;
end;

procedure TfPrincipal.PesquisarProduto;
begin
  try
    if (ModelPesquisa.PesquisarProduto('codigo', 'codigo', edtCodigoProd.Text, 'ViewProdutos')) then
    begin
      edtCodigoProd.Text := ModelPesquisa.qryProdutoscodigo.AsString;
      edtDescricao.Text  := ModelPesquisa.qryProdutosdescricao.AsString;
      edtValProduto.Text := FormatCurr('0.00', ModelPesquisa.qryProdutosval_venda.AsCurrency);
      edtQtdProduto.Text := '1';

      edtQtdProduto.SetFocus;

      mtItensPedidos.Append;
    end
    else
    begin
      ShowMessage('Produto não localizado !!!!');
      LimparItens;
    end;
  finally
    ModelPesquisa.qryProdutos.Close;
    ModelPesquisa.qryProdutos.SQL.Text := ModelPesquisa.gSQLOri;
  end;

end;

// Essa função pode ser incluida diretamente em um template e herdado em cada tela do sistema sobrescrevendo caso necessário
procedure TfPrincipal.PreencherPedido(Pedido: IPedido);
var
  Context   : TRttiContext;
  TypObj    : TRttiType;
  Prop      : TRttiProperty;
  Component : TWinControl;
begin
  Context   := TRttiContext.Create;
  TypObj    := Context.GetType(TObject(Pedido).ClassInfo);
  try
    for Prop in TypObj.GetProperties do
    begin
      Component := TWinControl(FindComponent('edt'+Prop.Name));
      if Assigned(Component) then begin
        if (Component is TEdit) then
        begin
          if (Prop.GetValue(TObject(Pedido)).Kind = tkFloat) then
            TEdit(Component).Text := FormatCurr('0.00', Prop.GetValue(TObject(Pedido)).AsCurrency)
          else
            TEdit(Component).Text := Prop.GetValue(TObject(Pedido)).ToString
        end
        else if (Component is TMemo) then
          TMemo(Component).Text := Prop.GetValue(TObject(Pedido)).ToString
        else
          raise Exception.Create('Tipo não tratado');
      end;
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

end.
