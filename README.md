# ATT (Apk testing tool) v1.13

apk 파일의 검색 및 추출, 디코딩, 빌드, java 소스, 사이닝, 인스톨 작업만 처리할 수 있도록 만든 간단한 배치파일 입니다. 메뉴 형태의 모드와 커맨드라인 모드로 사용 가능합니다. adb.exe, apktool등은 하위 디렉토리에 포함하고 있습니다. java 패스는 설정되어 있어야 합니다(어느 디렉토리에서나 java 커맨드 실행이 가능하도록)
- att 실행시나 또는 사용도중 오류가 난다면...
- att가 복사된 디렉토리 경로에 ( ) 가 있나요? --> ( ) 가 없는 경로에서 실행해주세요. 이건 차후에 수정 예정..
- 경로에 괄호가 없는데도 오류가 난다면 경로에 ' '(공백)이 있는지 확인해보세요. 대부분의 경우 공백이 있어도 작동하도록 수정했으나, 아직 미처 발견하지 모류가 있을지도 모르겠네요. 혹시 모르니 공백이 없는 경로에서 한번 사용해보세요.

<br/>

## 변경사항
-v.1.13
- 코드 구조 변경 

-v.1.12
- 앱 홈디렉토리내 파일을 PC로 추출하는 명령 추가

-v.1.10
- 10번 메뉴 오류 수정..
- 경로에 space 가 있을 경우 발생하는 몇가지 오류 수정
- 코드 분석 시 문자열 검색을 조금 편리하게 할 수 있도록, 한글 문자열과 Unicode 값을 서로 변환할 수 있는 메뉴를 간단한 파이선 코드로 추가하였습니다. (예: '가나다' <--> '\uac00\ub098\ub2e4')
- 중간에 특수문자나 공백이 있어도 변환됩니다. 다만 중간에 공백이 있는 문자열을 입력할 때는 " "(double quote)로 감싸주어야 합니다. 이것은 배치파일의 한계라 불편해도 어쩔수 없습니다.

<br/>

## 사용법
### 메뉴 형태 실행 : att.bat
- 메뉴 형태로 실행하면 모든 디렉토리는 att.bat 가 존재하는 디렉토리를 기준으로 처리합니다.
- 모든 명령은 source 디렉토리에 존재하는 apk 파일이름을 기준으로 프로젝트로 처리됩니다. (output 경로에 apk 파일 이름으로 디렉토리를 생성하여 관리)
- 즉, 예를들어서 output/dist/test.apk 파일을 Signing 하는 작업을 명령한다고 할 때에도 해당 위치의 실제 파일을 지정하는 것이 아니라 source 디렉토리에 있는 apk 파일 이름을 지정해주면 됩니다. 이러한 작업은 att가 알아서 리스트로 보여주므로 유저가 신경쓸 필요는 없습니다.
- 1번(search and pull apk) 명령으로 디바이스로부터 apk 파일을 pull 한 경우도 source 디렉토리에 저장됩니다.


### 커맨드라인 형태  : att.bat [p/d/b/j/s/i/h]
- 커맨드라인 형태로 실행하면 모든 디렉토리는 현재 디렉토리를 기준으로 처리합니다.
- 즉, apk 파일을 현재 디렉토리에서 찾으며(source 디렉토리 아님), output 디렉토리도 현재 디렉토리에 만듭니다. apk 파일이 저장된 별도의 디렉토리에 가서 작업하기 위한 의도입니다.
- 타겟 파일을 두번째 인자로 직접 명시해도 되지만 따로 명시하지 않을 경우 현재 디렉토리에 있는 apk 파일 목록을 보여줍니다.
- 모든 작업을 apk 파일 이름을 기준으로 프로젝트로 처리하는 것은 메뉴 모드일때와 같습니다.
- att.bat h 를 입력하면 HELP 페이지를 보여줍니다.


### 기타.
- 현재 포함되어 있는 apktool 버전은 2.3.3 입니다.

끝.


