import { config } from '../../config/index';
import { get } from '../../utils/request';

/** 获取商品详情页评论数 */
export function getGoodsDetailsCommentsCount(spuId = 0) {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getGoodsDetailsCommentsCount } = require('../../model/detailsComments');
    return delay().then(() => getGoodsDetailsCommentsCount(spuId));
  }
  return get('/v1/goods/comments-count', { spuId });
}

/** 获取商品详情页评论列表 */
export function getGoodsDetailsCommentList(spuId = 0) {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getGoodsDetailsComments } = require('../../model/detailsComments');
    return delay().then(() => getGoodsDetailsComments(spuId));
  }
  return get('/v1/goods/comments', { spuId });
}
