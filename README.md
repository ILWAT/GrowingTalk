# GrowingTalk
<img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/00f1a045-30e3-44da-8849-4acfe329a697" width="20%"></img><img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/a7e1d4d8-63af-4b3d-9d58-d1ca62916d7b" width="20%"></img><img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/8e944d10-dd5f-4ffe-801e-2ff82a6c2fbb" width="20%"></img><img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/451516cc-0276-4092-a553-0db474408852" width="20%"></img><img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/6c93b115-774d-4bb0-8447-27ec0070c983" width="20%"></img>


**🎙️협업을 통한 성장 공간, GrowingTalk**  



- 이메일 기반 회원 인증
- 워크스페이스(메인 화면) 내 채팅방 개설 기능 및 회원 초대 기능
- 실시간 채팅 기능 및 새로운 채팅 도착시 알림 기능
- 결제 시스템 기능 포함

<details>
<summary>더 자세한 스크린 샷 보기</summary>  
<div markdown="1">
<a href=https://github.com/ILWAT/GrowingTalk/pull/10)>🔗온보딩 화면</a></br>
<a href=https://github.com/ILWAT/GrowingTalk/pull/13>🔗회원가입</a></br>
<a href=https://github.com/ILWAT/GrowingTalk/pull/14>🔗로그인</a></br>
<a href=https://github.com/ILWAT/GrowingTalk/pull/18>🔗홈화면(워크스페이스)</a></br>
<a href=https://github.com/ILWAT/GrowingTalk/pull/20>🔗사이드 바</a></br>
<a href=https://github.com/ILWAT/GrowingTalk/pull/23>🔗채팅창 및 알림 기능</a></br>
<a href=https://github.com/ILWAT/GrowingTalk/pull/24>🔗PG결제</a></br>
</div>
</details> </br> 

----------

**📋핵심 기술**
- [`RxSwift`](https://github.com/ReactiveX/RxSwift) 기반 MVVM 패턴 적용을 통해 비즈니스 로직 분리 및 반응형 프로그래밍 구현
- [`Realm`](https://github.com/realm/realm-swift.git) DataBase에 기존 채팅 데이터를 쓰기/읽기하여  네트워크 Reqeust 최소화
- [`SocketIO`](https://github.com/socketio/socket.io-client-swift.git)를 활용한 Socket 통신 기반 실시간 채팅 구현
- Payment Gateway(PG)를 통한 신용 카드 결제 지원 
- `Modern CollectionView` + `DiffableDataSource`를 활용한 Expandable List 구현
- `Async/Await`를 도입한 Realm Transaction 비동기 실행 구현
- `Rx operator`를 활용한 `JWT기반 AccessToken, Refresh Token 갱신 로직` 구현
- `UIGraphicsImageRenderer`를 통한 이미지 Rendering resizing
- 공통 UI Component 분리 및 캡슐화 구현을 통한 재 사용성 향상




## 🛠️개발
***🌎개발 환경***
> 개발 기간: 2024.01.02. ~ 03.01.  
> 개발 인원: 1인  
> 개발 언어: Swift  
> Minimum Deployment: iOS 16.0+: `UISheetPresentationController.Detent.custom`
---------
***⚙️기술 스택***
- **BaseSDK**: `UIKit`
- **Pattern**: `MVVM`, `Singleton`, `Input-Output Pattern`
- **Reactive Programming**: `RxSwift`
- **Package Management**: `SPM`, `CocoaPods`
- **CodeBaseUI**: `PHPickerViewController`, `SnapKit`, `Then`, `Toast`
- **Database**: `RealmSwift`
- **Network**: `Moya`, `SocketIO`, `Kingfisher`
- **Management**: `FireBase Cloud Messaging`  

## 🔥개발 Point
### 사이드 바 구현
- 사이드 바를 구현하기 위해 라이브러리를 사용할 수 있으나, 보편적인 사이드 바 구현 **라이브러리는 지원이 끊긴지 오래 되었음**에 따라 사이드 바 **직접 구현**을 선택.
- `UIView.animate()`를 통해 ViewWillAppear 시점과 viewWillDisappear 시점에서의 애니메이션을 구현.
- `UIPanGestureRecognizer`를 통해 뷰의 `Animate`를 적용하고 **View의 dismiss를 결정**할 수 있다.

### 채팅 로직
<img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/756a373a-0bb1-4887-b3e2-51c894e70cca" width="60%"></img>
- 서버에서 채팅 내역에 대한 데이터를 받을 때, 모든 채팅 내역을 받게되면 채팅을 하면 할수록 서버 및 통신에 대해서 비용이 너무 커지게 된다.
- 그렇기 때문에 서버로부터 이미 받은 채팅 내역에 대해서는 로컬에 저장하여 CRD하는 방식으로 구현한 뒤, 로컬에서의 마지막 채팅을 기준으로 그 이후 채팅 내역을 받는 것으로 비용을 절감할 수 있다.
- 로컬 DB에 저장되어 있는 채팅내역, 서버 통신을 통해 채팅 내역을 받아오고 나면 `Socket`을 통해 실시간 데이터를 받아 채팅을 구현한다.
  



## ⚠Trouble Shooting
### 사이드바의 constraints + animate 문제: (`Main event loop`의 이해)
|문제 상황|정상|
|:--:|:--:|
|<img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/6a4afd3b-0eb9-4001-b1e0-16a2aef8d715" width="20%"></img> |<img src="https://github.com/ILWAT/GrowingTalk/assets/87518434/da5ad0d6-a93c-457b-8363-b7465e8cede3" width="20%"></img>|

#### 문제점
- 사이드 바의 등장 애니메이션 효과를 적용하기 위해 사이드 바의 View 초기 위치를 너비만큼 현재 View로부터 음수 방향으로 Constraints를  viewDidLoad시점에 설정한 다음, ViewWillAppear 시점에 Constraints를 현재 View로 맞춰주어 UIView.animate() 메서드를 실행했으나, 뷰의 애니메이션이 **X 좌표 뿐만 아니라 Y좌표도 같이 Animation이 실행되는 문제점**이 발생
```Swift
private func sideBarAppearAnimation() {
      self.sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.view.layoutIfNeeded()
        }
}
```

#### 원인 및 해결
- 디버깅을 진행했을 때, viewWillAppear시점 전까지 사이드바 View의 초기 크기 및 위치가 모두 정해지지 않는 상태임을 확인
- `Main event loop`의 개념이 필요함.
  - 무작정 Constraints를 설정했다고 해서 바로 View에 Constraints가 적용되어 뷰의 위치와 크기가 결정되는 것이 아님.
  - `Main run loop`의 시점이 동작되어야 비로소 실질적 Constraints가 적용되어 뷰의 위치와 크기가 결정됨.
  - UIView.animate()는 Scope내에서의 View 변경사항을 그 이전과 비교하여 애니메이션을 실행하는 구조로 동작함.
  - 그렇기 때문에 ViewDidLoad() 실행 시점과 ViewWillAppear()가 실행되는 시점의 차이가 굉장히 짧은 경우, 실질적인 초기 Constraints가 적용되기 전에 Constratints가 덮어쓰기 되어 좌표(0, 0)과 Frame(0, 0)에 상태에서 최종 애니메이션이 실행되는 것이기에 이러한 문제가 발생.
  - Constraints가 덮어쓰기 되기 전에 `Main run loop`를 임의로 동작시켜 초기 뷰를 설정해 준 다음, Constraints를 바꾸어 animate를 실행하면 해당 문제가 해결됨.
```Swift
private func sideBarAppearAnimation() {
        self.view.layoutIfNeeded() //AutoLayout을 통해 뷰의 초기 위치와 크기를 잡았기에 애니메이션을 해당 메서드 실행 -> 뷰가 실제로 보여지기 전까지 초기 AutoLayout은 실행되지 않음.
        sideBarView.snp.updateConstraints { make in
            make.leading.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
```

### 네비게이션 바의 UIBarButtonItem의 크기가 조절되지 않는 문제

|문제 상황|정상|
|:--:|:--:|
|<img width="341" alt="네비게이션 바 오류" src="https://github.com/ILWAT/GrowingTalk/assets/87518434/8990699d-9f56-41c7-9586-0292c19e1cd7">|<img width="314" alt="네비게이션 바 정상" src="https://github.com/ILWAT/GrowingTalk/assets/87518434/fc514b2e-e4da-4a34-885c-2f8681d8100f">|


- Left Bar Button Item을 기획 및 디자인에 맞추어 버튼 크기의 설정이 필요함.
  ```Swift
    let workSpaceImageButton = UIButton().then { view in
        view.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        let defaultImage = UIImage(named: "WorkSpace")
        view.setBackgroundImage(defaultImage, for: .normal)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
    }

    lazy var workSpaceImageBarButton =  UIBarButtonItem(customView: workSpaceImageButton)

    ...

    navigationItem.setLeftBarButton(workSpaceImageBarButton, animated: true)

- 이 상황에서 버튼의 사이즈를 **Constraints 혹은 Frame으로 크기를 설정해 주어도 지정한 사이즈대로 구현되지 않는 문제** 발생.
- `UIButton`안의 image를 설정하는 경우, **설정한 image의 크기에 따라 button내 ImageView의 크기가 결정되고 button은 해당 imageView의 크기보다 작게 설정될 수 없기 때문에 해당 문제가 발생하는 것을 확인.**
- button 내 image를 설정하고 싶은 button의 사이즈보다 작게 resizing하여 button의 사이즈를 설정해주면 정상적으로 사이즈 조절이 가능.

  ```Swift
    let workSpaceImageButton = UIButton().then { view in
        view.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        let defaultImage = UIImage(named: "WorkSpace")?.resizingByRenderer(size: CGSize(width: 30, height: 30), tintColor: .BackgroundColor.backgroundPrimaryColor)
        view.setBackgroundImage(defaultImage, for: .normal)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
    }
    
    lazy var workSpaceImageBarButton =  UIBarButtonItem(customView: workSpaceImageButton)
    
    ...

    navigationItem.setLeftBarButton(workSpaceImageBarButton, animated: true)



## 📔회고
- 최초로 PG사의 SDK를 통해 결제를 달 수 있어, **결제 시스템 구현에 대한 두려움이 해소**되었다.
- 열거형을 RawValue로 초기화 해야하는 상황에서 추상화를 하기 위해 많은 고민을 끝에 `RawValue Protocol`을 알게되었고 이를 통해 NetworkError에 관해서 추상화하여 Generic사용이 가능하게 하여 재사용성을 높일 수 있게 되었다.
- Moya의 TargetType(Router Pattern)을 **DI를 통해 분리**를 했다면 유지보수성이 좋고 간결한 코드를 작성할 수 있을 것 같지만 실제로 적용하지 못해 아쉽다.


