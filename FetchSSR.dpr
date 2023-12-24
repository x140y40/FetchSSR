program FetchSSR;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, Classes, WinInet, StrUtils, winsock2;

type
  TFriend = record
    name: string[10];
    age : integer;
  end;
  PFriend = ^TFriend;

var
  FriendList    : TList;
  FriendFileName: string;

//const
//  LeftTop    = '┛';
//  LeftBottom = '┓';
//
//  Level      = '━';
//
//  RightBottom = '┏';
//  RightTop    = '┗';
//
//  Cross       = '╋';
//
//  Vertical    = '┃';
//
//  Right       = '┣';
//  Left        = '┫';
//
//  Bottom      = '┳';
//  Top         = '┻';
      {
function GetWebPage(const URL: string; ShowHeaders: boolean = false): string;
const
  Agent = 'Internet Explorer 6.0';
var
  hFile, HInet: HINTERNET;
  Buffer: array[0..32767] of Char;
  BufRead: Cardinal;
  BufSize: Cardinal;
  TempStream: TStringStream;
  dwIndex: dword;
begin
  HInet := InternetOpen(PChar(Agent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(HInet) then
  try
    hFile := InternetOpenUrl(HInet, PChar(URL), nil, 0, 0, 0);

    TempStream := TStringStream.Create('');

    dwIndex := 0;
    BufSize := SizeOf(Buffer);

    HttpQueryInfo(hfile, HTTP_QUERY_RAW_HEADERS_CRLF, @Buffer, BufSize, dwIndex);

    if ShowHeaders then TempStream.Write(Buffer, BufSize);

    if Assigned(hFile) then
    try
      with TempStream do
      try
        while InternetReadFile(hFile, @Buffer, BufSize, BufRead) and (BufRead > 0) do
          Write(Buffer, BufRead);
        Result := DataString;
      finally
        Free;
      end;
    finally
      InternetCloseHandle(hFile);
    end;
  finally
    InternetCloseHandle(hinet);
  end;
end;

function GetWebPage(const Url:string):string;
    const
    BuffSize     = 64*1024;
    TitleTagBegin='<title>';
    TitleTagEnd  ='</title>';
    var
      hInter   : HINTERNET;
      UrlHandle: HINTERNET;
      BytesRead: Cardinal;
      Buffer   : Pointer;
      i,f      : Integer;
    begin
      Result:='';
   //   hInter := InternetOpen('', INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
      hInter:= InternetOpen(PChar('YourAppName'), INTERNET_OPEN_TYPE_DIRECT,
    nil, nil, INTERNET_FLAG_OFFLINE);
      if Assigned(hInter) then
      begin
        GetMem(Buffer,BuffSize);
        InternetSetOption(hInter, INTERNET_OPTION_SETTINGS_CHANGED, nil, 0);
        try
           UrlHandle := InternetOpenUrl(hInter, PChar(Url), nil, 0, INTERNET_FLAG_RAW_DATA,0);
           try
            if Assigned(UrlHandle) then
            begin
              InternetReadFile(UrlHandle, Buffer, BuffSize, BytesRead);
              if BytesRead>0 then
              begin
                SetString(Result, PAnsiChar(Buffer), BytesRead);
                i:=Pos(TitleTagBegin,Result);
                if i>0 then
                begin
                  f:=PosEx(TitleTagEnd,Result,i+Length(TitleTagBegin));
                  Result:=Copy(Result,i+Length(TitleTagBegin),f-i-Length(TitleTagBegin));
                end;
              end;
            end;
           finally
             InternetCloseHandle(UrlHandle);
           end;
        finally
          FreeMem(Buffer);
        end;
        InternetCloseHandle(hInter);
      end
    end; }


function SockAddrToString(pAddr: LPSOCKADDR; AddrSize: DWORD): String;
var
  Buf: array[0..40] of Char;
  Len: DWORD;
begin
  Result := '';
  Len := Length(Buf);
  if WSAAddressToString(pAddr, AddrSize, nil, Buf, Len) = 0 then
    SetString(Result, Buf, Len-1);
end;

procedure StatusCallback(Handle: HInternet; Context: DWord;
  Status: DWord; Info: Pointer; StatLen: DWord); stdcall;
begin
  with PRequestInfos(Context)^ do
    if not IgnoreMsg then
      case Status of
        INTERNET_STATUS_CLOSING_CONNECTION:
          if Assigned(Grabber.FOnClosing) then
            Grabber.FOnClosing(Grabber, UserData, Url);
        INTERNET_STATUS_CONNECTED_TO_SERVER:
          if Assigned(Grabber.FOnConnected) then
            Grabber.FOnConnected(Grabber, UserData, Url);
        INTERNET_STATUS_CONNECTING_TO_SERVER:
          if Assigned(Grabber.FOnConnecting) then
            Grabber.FOnConnecting(Grabber, UserData, Url);
        INTERNET_STATUS_NAME_RESOLVED:
          if Assigned(Grabber.FOnResolved) then
            Grabber.FOnResolved(Grabber, UserData, Url, StrPas(PChar(Info)));
        INTERNET_STATUS_RECEIVING_RESPONSE:
          if Assigned(Grabber.FOnReceivingResponse) then
            Grabber.FOnReceivingResponse(Grabber, UserData, Url);
        INTERNET_STATUS_REDIRECT:
          if Assigned(Grabber.FOnRedirect) then
            Grabber.FOnRedirect(Grabber, UserData, Url, StrPas(PChar(Info)));
        INTERNET_STATUS_REQUEST_COMPLETE:
          if Assigned(Grabber.FOnRequestComplete) then
            Grabber.FOnRequestComplete(Grabber, UserData, Url);
        INTERNET_STATUS_REQUEST_SENT:
          if Assigned(Grabber.FOnRequestSent) then
            Grabber.FOnRequestSent(Grabber, UserData, Url, DWORD(Info^));
        INTERNET_STATUS_RESOLVING_NAME:
          if Assigned(Grabber.FOnResolving) then
            Grabber.FOnResolving(Grabber, UserData, Url);
        INTERNET_STATUS_RESPONSE_RECEIVED:
          if Assigned(Grabber.FOnReceived) then
            Grabber.FOnReceived(Grabber, UserData, Url, DWORD(Info^));
        INTERNET_STATUS_SENDING_REQUEST:
          if Assigned(Grabber.FOnSendingRequest) then
            Grabber.FOnSendingRequest(Grabber, UserData, Url);
      end;
end;


function GetWebPage(const URL: string; ShowHeaders: boolean = false): string;
const
  Agent = 'Internet Explorer 6.0';
var
  hFile, HInet: HINTERNET;
  Buffer: array[0..32767] of Char;
  BufRead: Cardinal;
  BufSize: Cardinal;
  TempStream: TStringStream;
  dwIndex: dword;
begin
  HInet := InternetOpen(PChar(Agent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(HInet) then
  try
    hFile := InternetOpenUrl(HInet, PChar(URL), nil, 0, 0, 0);

    TempStream := TStringStream.Create('');

    dwIndex := 0;
    BufSize := SizeOf(Buffer);
    InternetSetStatusCallback(hRequest, @StatusCallback);
    HttpQueryInfo(hfile, HTTP_QUERY_RAW_HEADERS_CRLF, @Buffer, BufSize, dwIndex);

    if ShowHeaders then TempStream.Write(Buffer, BufSize);

    if Assigned(hFile) then
    try
      with TempStream do
      try
        while InternetReadFile(hFile, @Buffer, BufSize, BufRead) and (BufRead > 0) do
          Write(Buffer, BufRead);
        Result := DataString;
      finally
        Free;
      end;
    finally
      InternetCloseHandle(hFile);
    end;
  finally
    InternetCloseHandle(hinet);
  end;
end;

  {
function GetWebPage(Url: string): string;
var
  hSession, hConnect, hRequest: hInternet;
  FHost, FScript, SRequest, Uri: string;
  Ansi: PAnsiChar;
  Buff: array [0..1023] of Char;
  BytesRead: Cardinal;
  Res, Len: DWORD;
  https: boolean;
const
  Header='Content-Type: application/x-www-form-urlencoded' + #13#10;
begin
  https:=false;
  if Copy(LowerCase(Url),1,8) = 'https://' then https:=true;
  Result:='';

  if Copy(LowerCase(Url), 1, 7) = 'http://' then Delete(Url, 1, 7);
  if Copy(LowerCase(Url), 1, 8) = 'https://' then Delete(Url, 1, 8);

  Uri:=Url;
  Uri:=Copy(Uri, 1, Pos('/', Uri) - 1);
  FHost:=Uri;
  FScript:=Url;
  Delete(FScript, 1, Pos(FHost, FScript) + Length(FHost));

  hSession:=InternetOpen('Mozilla/4.0 (MSIE 6.0; Windows NT 5.1)', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if not Assigned(hSession) then exit;
  try
    if https then hConnect:=InternetConnect(hSession, PChar(FHost), INTERNET_DEFAULT_HTTPS_PORT, nil,'HTTP/1.0', INTERNET_SERVICE_HTTP, 0, 0) else
      hConnect:=InternetConnect(hSession, PChar(FHost), INTERNET_DEFAULT_HTTP_PORT, nil, 'HTTP/1.0', INTERNET_SERVICE_HTTP, 0, 0);
    if not Assigned(hConnect) then exit;
    try
      Ansi:='text/*';
      if https then
        hRequest:=HttpOpenRequest(hConnect, 'GET', PChar(FScript), 'HTTP/1.1', nil, @Ansi, INTERNET_FLAG_SECURE, 0)
      else
        hRequest:=HttpOpenRequest(hConnect, 'GET', PChar(FScript), 'HTTP/1.1', nil, @Ansi, INTERNET_FLAG_RELOAD, 0);
      if not Assigned(hConnect) then Exit;
        try
          if not (HttpAddRequestHeaders(hRequest, Header, Length(Header), HTTP_ADDREQ_FLAG_REPLACE or HTTP_ADDREQ_FLAG_ADD or HTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA)) then
            exit;
          Len:=0;
          Res:=0;
          SRequest:=' ';
          HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF or HTTP_QUERY_FLAG_REQUEST_HEADERS, @SRequest[1], Len, Res);
          if Len > 0 then begin
            SetLength(SRequest, Len);
            HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF or HTTP_QUERY_FLAG_REQUEST_HEADERS, @SRequest[1], Len, Res);
          end;
          if not (HttpSendRequest(hRequest, nil, 0, nil, 0)) then // www.delphitop.com
            exit;
          FillChar(Buff, SizeOf(Buff), 0);
          repeat
            //Application.ProcessMessages;
            Result:=Result + Buff;
            FillChar(Buff, SizeOf(Buff), 0);
            InternetReadFile(hRequest, @Buff, SizeOf(Buff), BytesRead);
          until BytesRead = 0;
        finally
          InternetCloseHandle(hRequest);
        end;
    finally
      InternetCloseHandle(hConnect);
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end;


function GetWebPage(const Url: string):string;
var
  Session,
  HttpFile:HINTERNET;
  szSizeBuffer:Pointer;
  dwLengthSizeBuffer:DWord;
  dwReserved:DWord;
  dwFileSize:DWord;
  dwBytesRead:DWord;
  Contents:PChar;
begin
  Session:=InternetOpen('',0,niL,niL,0);
  HttpFile:=InternetOpenUrl(Session,PChar(Url),niL,0,0,0);
  dwLengthSizeBuffer:=1024;
  HttpQueryInfo(HttpFile,5,szSizeBuffer,dwLengthSizeBuffer,dwReserved);
  GetMem(Contents,dwFileSize);
  InternetReadFile(HttpFile,Contents,dwFileSize,dwBytesRead);
  InternetCloseHandle(HttpFile);
  InternetCloseHandle(Session);
  Result:=StrPas(Contents);
  FreeMem(Contents);
end;  }

procedure LoadFriendFrmFile();
  procedure AddFriendItem(S: string);
  var
    strList: TStringList;
    P: PFriend;
  begin
    if Length(s) < 0  then exit;
    strList := TStringList.Create();
    try
      strList.Delimiter := '|';
      strList.DelimitedText := S;

      New(p);
      P^.name := strList.Strings[0];
      P^.age  := strToIntDef(strList.Strings[1], -1);

      FriendList.Add(P);

    finally
      strList.Free();
    end;
  end;
var
  F: TextFile;
  S: string;
begin
  if not FileExists(FriendFileName) then exit;
  AssignFile(F, FriendFileName);
  try
    Reset(F);
    while not Eof(F) do
    begin
      Readln(F, S);
      AddFriendItem(S);
    end;
  finally
    CloseFile(F);
  end;
end;

procedure SaveFriendToFile();
var
  F: TextFile;
  S: string;
  I: integer;
  P: PFriend;
begin
  if not Assigned(FriendList) then exit;
  if FriendList.Count <= 0 then

  AssignFile(F, FriendFileName);
  try
    ReWrite(F);
    for i := 0 to FriendList.Count - 1 do
    begin
      P := FriendList.Items[I];
      S := P^.name + '|' + IntToStr(P^.age);
      Writeln(s);
    end;
  finally
    CloseFile(F);
  end;
end;

procedure Description();
begin
  Writeln('┏━━━━━━━━━━━━━━┓');
  Writeln('┃         好友管理           ┃');
  Writeln('┃============================┃');
  Writeln('┃1.A/a 添加新的好友。        ┃');
  Writeln('┃2.M/m 修改好友年龄信息。    ┃');
  Writeln('┃3.D/d 通过好友姓名删除好友。┃');
  Writeln('┃4.P/p 查看好友信息。        ┃');
  Writeln('┃5.F/f 查找好友信息。        ┃');
  Writeln('┃6.E/e 退出。                ┃');
  Writeln('┃7.S/s 获取SSR。                ┃');
  Writeln('┗━━━━━━━━━━━━━━┛');
end;

function CheckStr(S: string): boolean;
var
  i: integer;
const
  FLAG = '!@#$%^&*()_+-=[]{},./<>?:"|;''\0123456789';

begin
  Result := false;
  for i := 1 to Length(FLAG) do
  begin
    if Pos(FLAG[i], S) > 0 then
    begin
      Result := true;
      Writeln('输入的姓名不合法！');
      break;
    end;
  end;
end;

function GetName(): string;
var
  S: string;
begin
  repeat
    write('请输入姓名: ');
    ReadLn(s);
  until ((Length(s) <= 10) and (not CheckStr(s)));
  Result := S;
end;

function GetAge(): integer;
var
  S: string;
  R: integer;
begin
  R := -1;

  while TRUE do
  begin
    write('请输入年龄: ');
    ReadLn(S);
    if ((not TryStrToInt(S, R)) and (R <= 0)) then
      writeln('输入的年龄不合法')
    else
      break;
  end;

  Result := R;
end;

procedure AddFriend();
var
  P: PFriend;
begin
  New(p);
  P^.name := GetName();
  P^.age  := GetAge();
  FriendList.Add(P);
end;

function GetFriendFrmName(name: string): PFriend;
var
  I: integer;
  P: PFriend;
begin
  Result := nil;
  for I := 0 to FriendList.Count - 1 do
  begin
    P := FriendList.Items[I];
    if P^.name = name then
    begin
      Result :=  P;
      break;
    end;
  end;
end;

procedure ModifyFriend();
var
  P: PFriend;
begin
  P := GetFriendFrmName(GetName());
  if Assigned(p) then
  begin
    P^.age := GetAge();
  end
  else
    Writeln('好友不存在！');
end;

procedure DeleteFriend();
var
  P: PFriend;
  I: integer;
  name: string;
  B: boolean;
begin
  name := GetName();
  B := false;
  for I := 0 to FriendList.Count - 1 do
  begin
    P := FriendList.Items[I];
    if P^.name = name then
    begin
      Dispose(P);
      FriendList.Delete(I);
      B := true;
      break;
    end;
  end;

  if B = false then
    Writeln('好友不存在！');
end;

procedure PrintTitle();
begin
  Writeln('┏━━━━━┳━━━━━┳━━━━━┓');
  Writeln('┃index     ┃Name      ┃Age       ┃');
end;

procedure PrintBottom();
begin
  Writeln('┗━━━━━┻━━━━━┻━━━━━┛');
end;

procedure FindFriend();
var
  P: PFriend;
  S: string;
begin
  P := GetFriendFrmName(GetName());
  if Assigned(P) then
  begin
    PrintTitle();
    Writeln('┣━━━━━╋━━━━━╋━━━━━┫');
    Writeln(Format('┃%-10d┃%-10s┃%-10d┃', [1, P^.name, P^.age]));
    PrintBottom();
  end
  else
    Writeln('好友不存在！');
end;

procedure PrintFriend();
var
  I: integer;
  P: PFriend;
begin
  if FriendList.Count > 0 then
  begin
    PrintTitle();
    for I := 0 to FriendList.Count - 1 do
    begin
      P := FriendList.Items[I];
      Writeln('┣━━━━━╋━━━━━╋━━━━━┫');
      Writeln(Format('┃%-10d┃%-10s┃%-10d┃', [I + 1, P^.name, P^.age]));
    end;
    PrintBottom();
  end;
end;

procedure GetSSR();
var
  I: integer;
  sHtml: string;
begin
  sHtml:= GetWebPage('https://3.weiwei.in/2020.html');
  Writeln(sHtml);
 end;


procedure GetInput();
var
  s: string;
begin
  Description();
  write('请输入命令: ');
  Readln(s);
  while true do
  begin
    s := LowerCase(s);
    case s[1] of
    'a':
      begin
        AddFriend();
      end;
    'm':
      begin
        ModifyFriend();
      end;
    'd':
      begin
        DeleteFriend();
      end;
    'p':
      begin
        PrintFriend();
      end;
    'f':
      begin
        FindFriend();
      end;
    's':
      begin
        GetSSR();
      end;
    'e':
      begin
        break;
      end;
    else
      writeln('输入的命令不存在！');
    end;
    write('请输入命令: ');
    Readln(s);
  end;
end;

procedure InitFriend();
begin
  FriendList := TList.Create();
  LoadFriendFrmFile();
end;

procedure FreeFriend();
var
  P: PFriend;
  I: integer;
begin
  if FriendList.Count > 1 then
  begin
    repeat
      I := FriendList.Count - 1;
      P := FriendList.Items[I];
      Dispose(p);
      FriendList.Delete(I);
    until FriendList.Count = 0;
  end;

  FreeAndNil(FriendList);
end;


begin
  FriendFileName := ExtractFilePath(paramstr(0)) + 'friend.txt';
  InitFriend();
  GetInput();
  FreeFriend();
end.
