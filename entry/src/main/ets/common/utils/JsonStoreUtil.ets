/**
 * JsonStoreUtil - JSON 数据存储工具
 *
 * 职责：
 * 1. 从 rawfile 读取初始模拟数据（只读，随 APP 打包）
 * 2. 用户编辑后的数据写入应用沙箱（可读写）
 * 3. 「先读沙箱、无则读 rawfile 回退」策略
 *
 * 使用方式：
 *   const data = await JsonStoreUtil.read<CourseItem[]>('schedule.json');
 *   await JsonStoreUtil.write('schedule.json', modifiedData);
 */
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

export class JsonStoreUtil {
  /**
   * 读取 JSON 数据：优先读沙箱文件，不存在则从 rawfile 回退
   */
  static async read<T>(fileName: string): Promise<T | null> {
    try {
      const sandboxPath: string = getContext().filesDir + '/' + fileName;
      const text: string = fileIo.readTextSync(sandboxPath);
      return JSON.parse(text) as T;
    } catch (_e) {
      return JsonStoreUtil.readFromRaw<T>(fileName);
    }
  }

  /**
   * 从 rawfile 读取初始 JSON 数据
   */
  static async readFromRaw<T>(fileName: string): Promise<T | null> {
    try {
      const mgr = getContext().resourceManager;
      const data: Uint8Array = await mgr.getRawFileContent(fileName);
      const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
      const text: string = decoder.decodeToString(data);
      return JSON.parse(text) as T;
    } catch (e) {
      console.error('[JsonStoreUtil] rawfile 读取失败: ' + fileName + ' ' + JSON.stringify(e));
      return null;
    }
  }

  /**
   * 同步读沙箱文件（用于非 async 场景，如 Builder 初始化）
   */
  static readSync<T>(fileName: string): T | null {
    try {
      const sandboxPath: string = getContext().filesDir + '/' + fileName;
      const text: string = fileIo.readTextSync(sandboxPath);
      return JSON.parse(text) as T;
    } catch (_e) {
      return null;
    }
  }

  /**
   * 写入 JSON 数据到沙箱文件
   */
  static async write<T>(fileName: string, data: T): Promise<void> {
    try {
      const sandboxPath: string = getContext().filesDir + '/' + fileName;
      const text: string = JSON.stringify(data, null, 2);
      const file: fileIo.File = fileIo.openSync(sandboxPath,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, text);
      fileIo.closeSync(file);
    } catch (e) {
      console.error('[JsonStoreUtil] 沙箱写入失败: ' + fileName + ' ' + JSON.stringify(e));
    }
  }

  /**
   * 判断沙箱中是否存在某文件
   */
  static exists(fileName: string): boolean {
    try {
      const sandboxPath: string = getContext().filesDir + '/' + fileName;
      fileIo.openSync(sandboxPath, fileIo.OpenMode.READ_ONLY);
      return true;
    } catch (_e) {
      return false;
    }
  }
}
