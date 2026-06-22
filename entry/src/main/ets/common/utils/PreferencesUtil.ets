import { preferences } from '@kit.ArkData';
import { KEY_FIRST_LAUNCH, PREFERENCES_NAME } from '../constants/StorageKeys';

async function getLabPreferences(context: Context): Promise<preferences.Preferences> {
  return preferences.getPreferences(context, PREFERENCES_NAME);
}

export class PreferencesUtil {
  static async isFirstLaunch(context: Context): Promise<boolean> {
    const pref = await getLabPreferences(context);
    return (await pref.get(KEY_FIRST_LAUNCH, true)) as boolean;
  }

  static async markFirstLaunchComplete(context: Context): Promise<void> {
    const pref = await getLabPreferences(context);
    await pref.put(KEY_FIRST_LAUNCH, false);
    await pref.flush();
  }

  static async resetFirstLaunch(context: Context): Promise<void> {
    const pref = await getLabPreferences(context);
    await pref.put(KEY_FIRST_LAUNCH, true);
    await pref.flush();
  }
}
