/** 小程序网络请求工具 */

// 后端API基础地址（开发环境）
const BASE_URL = 'http://localhost:5000';

/**
 * 通用请求封装
 * @param {string} url - 请求路径
 * @param {string} method - 请求方法 GET/POST
 * @param {object} data - 请求参数
 * @returns {Promise}
 */
function request(url, method = 'GET', data = {}) {
  return new Promise((resolve, reject) => {
    wx.request({
      url: `${BASE_URL}${url}`,
      method: method,
      data: data,
      header: {
        'content-type': 'application/json; charset=UTF-8',
      },
      timeout: 15000,
      success(res) {
        if (res.statusCode === 200) {
          const result = res.data;
          // 后端统一返回格式: { errCode, errMessage, exceptionMsg, flag, resData }
          if (result.flag === true) {
            resolve(result.resData);
          } else {
            console.error('API Error:', result.exceptionMsg || result.errMessage);
            resolve(result.resData || null);
          }
        } else {
          console.error('HTTP Error:', res.statusCode);
          reject(new Error(`请求失败: ${res.statusCode}`));
        }
      },
      fail(err) {
        console.error('Request Fail:', err);
        reject(err);
      },
    });
  });
}

/**
 * GET请求
 */
function get(url, data = {}) {
  // 将参数转为query string
  const queryParts = [];
  Object.keys(data).forEach((key) => {
    if (data[key] !== undefined && data[key] !== null && data[key] !== '') {
      queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(data[key])}`);
    }
  });
  const queryStr = queryParts.length > 0 ? `?${queryParts.join('&')}` : '';
  return request(`${url}${queryStr}`, 'GET');
}

/**
 * POST请求
 */
function post(url, data = {}) {
  return request(url, 'POST', data);
}

module.exports = {
  get,
  post,
  request,
  BASE_URL,
};
