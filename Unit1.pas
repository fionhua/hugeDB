unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, DB, MemDS, DBAccess, MyAccess, math,
  RzStatus, ExtCtrls, RzPanel, Mask, ActnList, RzRadGrp;

type
  TForm1 = class(TForm)
    con1: TMyConnection;
    myqry1: TMyQuery;
    mmo1: TMemo;
    btn1: TBitBtn;
    rzstsbr1: TRzStatusBar;
    rzstspn1: TRzStatusPane;
    rzprgrsts1: TRzProgressStatus;
    btnSum: TBitBtn;
    edtIpAddr: TLabeledEdit;
    btnSum1: TBitBtn;
    btnCreate: TBitBtn;
    btnConnect: TBitBtn;
    edtUsr: TLabeledEdit;
    edtPwd: TLabeledEdit;
    edtPort: TLabeledEdit;
    actLst1: TActionList;
    actConnect: TAction;
    actCreateDB: TAction;
    rzchckgrp1: TRzCheckGroup;
    actAddRecord: TAction;
    actSum: TAction;
    actExit: TAction;
    procedure actConnectExecute(Sender: TObject);
    procedure actCreateDBExecute(Sender: TObject);
    procedure actAddRecordExecute(Sender: TObject);
    procedure actSumExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    function isConnect:Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.isConnect:Boolean;
begin
Result := con1.Connected;
if not result then
  if MessageDlg('mySQL数据库未连接，是否立即连接？',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    try
    con1.Connect;
    Result :=True;
    except on e:Exception do
      ShowMessage(Format('db连接失败：%s',[e.Message]));
    end;
end;

procedure TForm1.actConnectExecute(Sender: TObject);//连接数据
begin
con1.Close;
con1.Server:=Trim(edtIpAddr.Text);
con1.Port  :=StrToInt(edtPort.Text);
con1.Username:=Trim(edtUsr.Text);
con1.Password:=Trim(edtPwd.Text);
  try
  con1.Open;
  Beep;
  mmo1.Lines.Append('mySql数据库连接成功！');
  except on e:Exception do
    mmo1.Lines.Append(Format('db连接失败：%s',[e.Message]));
  end;
end;

procedure TForm1.actCreateDBExecute(Sender: TObject);//创建数据库wyhHuge、以及下属的数据表table1\teable2\table3
var i:Integer;
begin
if not isConnect then Exit;
myqry1.Close;
myqry1.SQL.Text:='Create Database If Not Exists wyhHugeDB Character Set UTF8';
  try//创建库wyhHugeDB
  myqry1.Execute;
  mmo1.Lines.Append('创建MySQL测试数据库[wyhHuge]完成。');
  Beep;
  except on e:Exception do
    mmo1.Lines.Append(Format('数据库 [wyhHugeDB]。',[e.Message]));
  end;
con1.Database:='wyhHugeDB';
for i:=1 to 3 do
  begin
  //3.创建新表
  myqry1.SQL.Text:=Format('CREATE TABLE IF NOT EXISTS `table%d` ('
    +'`id` int(11) NOT NULL AUTO_INCREMENT,'
    +'`bit1` bit(1) DEFAULT NULL,'
    +'`bit2` bit(1) DEFAULT NULL,'
    +'`int1` int(11) unsigned DEFAULT 0,'
    +'`int2` int(11) unsigned DEFAULT NULL,'
    +'`char1` char(32) DEFAULT NULL,'
    +'`char2` char(32) DEFAULT NULL,'
    +'`varchar1` varchar(64) DEFAULT NULL,'
    +'`varchar2` varchar(64) DEFAULT NULL,'
    +'PRIMARY KEY (`id`),'
    +'KEY `intIdx` (`int1`,`int2`) USING BTREE,'
    +'KEY `charIdx` (`char1`,`char2`) USING BTREE,'
    +'KEY `bitIdx` (`bit1`,`bit2`) USING BTREE,'
    +'KEY `varcharIdx` (`varchar1`,`varchar2`)'
    +') ENGINE=MyISAM DEFAULT CHARSET=utf8;',[i]);
    try//创建库海量数据表
    myqry1.Execute;
    mmo1.Lines.Append(Format('创建海量数据测试 [table%d] 完成。',[i]));
    Beep;
    except on e:Exception do
      mmo1.Lines.Append(Format('创建测试表 [table%d] 失败：',[e.Message]));
    end;
  end;
con1.Database:='wyhHugeDB';
end;

procedure TForm1.actAddRecordExecute(Sender: TObject);
var tmpString:String;
    m,n,i,o:Integer;
    int1,int2:Longword;
    bit1,bit2:ShortInt;
    chr1,chr2:string;
    vchr1,vchr2:WideString;
begin
  if not isConnect then Exit;
  con1.Database:='wyhHugeDB';
  Randomize;
  rzstspn1.Caption :='';
  myqry1.Close;
  for o:=0 to 2 do
    begin
    if not rzchckgrp1.ItemChecked[o] then Continue;
    mmo1.Lines.Append(Format('正在向table%d插入数据……',[o+1]));
    Application.ProcessMessages;
    rzprgrsts1.Percent:=0;
    for m:=1 to 100 do
      begin
      rzprgrsts1.Percent:=rzprgrsts1.Percent+1;
      Application.ProcessMessages;
      for n:=1 to 10000 do
        begin
        tmpString:='';
        bit1:=RandomRange(0,2);
        bit2:=RandomRange(0,2);
        int1:=random(1073741823);//30位二进制
        int2:=random(1073741823);
        chr1:='';
        chr2:='';
        for i:=1 to 16 do
          begin
          chr1 := chr1 + Chr(RandomRange(97,123));
          chr2 := chr2 + Chr(RandomRange(97,123));
          end;
        vchr1:='测试数据varChar类型' + Format('DR%.10d', [m*n]) + 'A';
        vchr2:='测试数据varChar类型' + Format('DR%.10d', [m*n]) + 'B';
        myqry1.SQL.Text:=Format('INSERT INTO table%d(`bit1`,`bit2`,`int1`,`int2`,`char1`,`char2`,`varchar1`,`varchar2`) VALUES(%d,%d,%d,%d,"%s","%s","%s","%s")',[o+1,bit1,bit2,int1,int2,chr1,chr2,vchr1,vchr2]);
        myqry1.Execute;
        end;
      end;
    mmo1.Lines.Append(Format('table%d插入1百万条数据完成。',[o+1]));
    Beep;
    Application.ProcessMessages;
    end;
end;

procedure TForm1.actSumExecute(Sender: TObject);//统计总记录数
var i,m:Integer;
begin
  if not isConnect then Exit;
  con1.Database:='wyhHugeDB';
  for i:=1 to 3 do
    begin
    myqry1.Close;
    myqry1.SQL.Text:=Format('select count(*) from table%d',[i]);
    myqry1.open;
    m:=myqry1.Fields[0].asInteger div 10000;
    mmo1.Lines.Append(Format('表[table%d]总记录数：%d 万条。',[i,m]));
    end;
end;

procedure TForm1.actExitExecute(Sender: TObject);
begin
con1.Disconnect;
Self.Close;
end;

end.
