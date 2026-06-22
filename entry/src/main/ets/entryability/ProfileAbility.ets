import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

// 用户信息接口定义
interface ProfileUserInfo {
  userId: string;
  username: string;
  major: string;
}

export default class ProfileAbility extends UIAbility {
  // 接收到的用户信息
  private userId: string = '';
  private username: string = '';
  private major: string = '';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onCreate');
    console.log('>>> [ProfileAbility] onCreate 被调用');
    console.log('>>> [ProfileAbility] 准备解析 Want 参数');

    // 解析从MainAbility传入的参数
    this.parseWantParams(want);
    console.log('>>> [ProfileAbility] 解析后 - userId: ' + this.userId + ', username: ' + this.username + ', major: ' + this.major);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onNewWant');
    // 单实例模式下，再次启动时解析新参数
    this.parseWantParams(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onWindowStageCreate');

    // 将用户信息存入AppStorage，供页面读取
    AppStorage.setOrCreate('profileUserId', this.userId);
    AppStorage.setOrCreate('profileUsername', this.username);
    AppStorage.setOrCreate('profileMajor', this.major);

    // 加载个人中心页
    windowStage.loadContent('pages/Profile', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'ProfileAbility onBackground');
  }

  // 解析Want参数，获取用户信息
  private parseWantParams(want: Want): void {
    try {
      const parameters = want.parameters as Record<string, string>;
      if (parameters) {
        this.userId = parameters['userId'] ?? '';
        this.username = parameters['username'] ?? '';
        this.major = parameters['major'] ?? '计算机科学与技术';
        hilog.info(DOMAIN, 'testTag', 'Received params - userId: %{public}s, username: %{public}s, major: %{public}s',
          this.userId, this.username, this.major);
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to parse want params. Cause: %{public}s', JSON.stringify(err));
    }
  }

  // 获取用户信息，供页面调用
  public getUserInfo(): ProfileUserInfo {
    return {
      userId: this.userId,
      username: this.username,
      major: this.major
    };
  }

  // 返回结果给调用方（terminateSelfWithResult使用）
  public getResultWant(): Want {
    return {
      parameters: {
        userId: this.userId,
        username: this.username,
        major: this.major
      }
    };
  }
}
