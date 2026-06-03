import { config } from '../../config/index';
import { get } from '../../utils/request';

/** 搜索商品（带分页、排序、筛选） */
export function fetchGoodsList(params) {
  if (config.useMock) {
    const { delay } = require('../_utils/delay');
    const { getSearchResult } = require('../../model/search');

    const data = getSearchResult(params);

    if (data.spuList.length) {
      data.spuList.forEach((item) => {
        item.spuId = item.spuId;
        item.thumb = item.primaryImage;
        item.title = item.title;
        item.price = item.minSalePrice;
        item.originPrice = item.maxLinePrice;
        item.desc = '';
        if (item.spuTagList) {
          item.tags = item.spuTagList.map((tag) => tag.title);
        } else {
          item.tags = [];
        }
      });
    }
    return delay().then(() => {
      return data;
    });
  }
  // 真实后端调用
  return get('/v1/goods/list', params);
}
