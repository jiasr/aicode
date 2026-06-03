import { config } from '../../config/index';
import { get } from '../../utils/request';

/** 获取单个商品详情 */
export function fetchGood(ID = 0) {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { genGood } = require('../../model/good');
    return delay().then(() => genGood(ID));
  }
  // 真实后端调用
  return get('/v1/goods/detail', { spuId: ID });
}
