import { config } from '../../config/index';
import { get } from '../../utils/request';

/** 获取商品列表 */
export function fetchGoodsList(pageIndex = 1, pageSize = 20) {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getGoodsList } = require('../../model/goods');
    return delay().then(() =>
      getGoodsList(pageIndex, pageSize).map((item) => {
        return {
          spuId: item.spuId,
          thumb: item.primaryImage,
          title: item.title,
          price: item.minSalePrice,
          originPrice: item.maxLinePrice,
          tags: item.spuTagList.map((tag) => tag.title),
        };
      }),
    );
  }
  // 真实后端调用
  return get('/v1/goods/simple-list', {
    pageIndex,
    pageSize,
  });
}
