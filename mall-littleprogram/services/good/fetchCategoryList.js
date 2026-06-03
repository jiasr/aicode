import { config } from '../../config/index';
import { get } from '../../utils/request';

/** 获取商品分类列表 */
export function getCategoryList() {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getCategoryList } = require('../../model/category');
    return delay().then(() => getCategoryList());
  }
  // 真实后端调用
  return get('/v1/goods/category');
}
