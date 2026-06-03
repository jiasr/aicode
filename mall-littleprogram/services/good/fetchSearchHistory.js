import { config } from '../../config/index';
import { get, post } from '../../utils/request';

/** 获取搜索历史 */
export function getSearchHistory() {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getSearchHistory } = require('../../model/search');
    return delay().then(() => getSearchHistory());
  }
  return get('/v1/goods/search-history');
}

/** 获取热门搜索 */
export function getSearchPopular() {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getSearchPopular } = require('../../model/search');
    return delay().then(() => getSearchPopular());
  }
  return get('/v1/goods/search-popular');
}

/** 添加搜索记录 */
export function addSearchHistory(keyword, userId) {
  if (config.useMock) {
    return Promise.resolve({ success: true });
  }
  return post('/v1/goods/search-add', { keyword, userId });
}
