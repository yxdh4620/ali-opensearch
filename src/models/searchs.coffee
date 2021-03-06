debuglog = require('debug')('ali-opensearch::models::actions')
assert = require "assert"
_ = require "underscore"
urlUtil = require 'url'
path = require 'path'
Signature = require "../utils/signature"
Tools = require '../utils/tools'

# 搜索文档(按id主键进行的搜索，所以没有分页和过滤)
# @public
# @param {String} id 主键的值
# @param {String|Array} fields 指定返回的字段，英文;符号分割 可以为Null(为Null,只返回主键数据)
# @param {String} format 返回数据格式（默认json）
# @return callback(err, data)
#   data(json格式)  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
#         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
searchById = (id, fields, format, callback) ->
  params = {}
  fields = Tools.makeFields(fields)
  params['fetch_fields'] = fields if fields?
  params['query'] = "config=format:#{format||'json'},start:0,hit:#{@pageSize}&&query=id:'#{id}'"
  header = Tools.generateHeader()
  #header['Content-MD5'] = ''
  uri = Tools.generateUri path.join(@URI_PREFIX, @appName, "/search"), params
  header['Authorization'] = Signature.generateAuthorization @GET_HTTP_METHOD, uri, header
  url = urlUtil.resolve @apiURL, uri
  @apiCall url, @GET_HTTP_METHOD, header, null, callback
  return

# 搜索文档(按多个id主键进行的搜索，目前没有分页和过滤)
# @public
# @param {String} id 主键的值
# @param {String|Array} fields 指定返回的字段，英文;符号分割 可以为Null(为Null,只返回主键数据)
# @param {String} filter 指定过滤条件 https://help.aliyun.com/document_detail/29158.html
# @param {String} format 返回数据格式（默认json）
# @return callback(err, data)
#   data(json格式)  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
#         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
searchByMultipleId = (ids, fields, filter, format, callback) ->
  queryStr = Tools.makeMultipleIdStr(ids)
  params = {}
  fields = Tools.makeFields(fields)
  params['fetch_fields'] = fields if fields?
  params['query'] = "config=format:#{format||'json'}&&query=#{queryStr}"
  header = Tools.generateHeader()
  #header['Content-MD5'] = ''
  uri = Tools.generateUri path.join(@URI_PREFIX, @appName, "/search"), params
  header['Authorization'] = Signature.generateAuthorization @GET_HTTP_METHOD, uri, header
  url = urlUtil.resolve @apiURL, uri
  @apiCall url, @GET_HTTP_METHOD, header, null, callback
  return

# 搜索文档
# @param {String} query 搜索子句参数（主要用来进行分页） https://help.aliyun.com/document_detail/29157.html
# @param {String|Array} fields 指定返回的字段，英文;符号分割 可以为Null(为Null,只返回主键数据)
# @param {String} filter 用来数据过滤的搜索子句参数 可以为Null(为Null,表示不进行过滤) https://help.aliyun.com/document_detail/29158.html
# @param {Object|String} config 搜索子句参数 https://help.aliyun.com/document_detail/29156.html
#      Object{start:第start个文档开始返回, hit: 返回文档的最大数量, format:返回格式(默认json), rerank_size:设置参与精排个数(200)}
# @param {String} sort 搜索子句参数 https://help.aliyun.com/document_detail/29159.html
# @param {String} aggregate 统计子句参数 https://help.aliyun.com/document_detail/29160.html
# @param {String} distinct  聚合子句参数 https://help.aliyun.com/document_detail/29161.html
# @param {Object|String} summary 飘红设置参数 https://help.aliyun.com/document_detail/57155.html
# @return callback(err, data)
#   data(json格式)  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
#         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
search = (query, fields, filter, config, sort, aggregate, distinct, summary, callback) ->
  return callback('missing query') unless query?
  params = {}
  fields = Tools.makeFields(fields)
  params['fetch_fields'] = fields if fields?
  params['query'] = "config=#{Tools.makeConfig(config, @pageSize)}&&query=#{query}"
  params['query'] += "&&filter=#{filter}" if filter?
  params['query'] += "&&sort=#{sort}" if sort?
  params['query'] += "&&aggegate=#{aggregate}" if aggregate?
  params['query'] += "&&distnct=#{distinct}" if distinct?
  params['summary'] = Tools.makeSummary(summary) if summary?
  header = Tools.generateHeader()
  #header['Content-MD5'] = ''
  uri = Tools.generateUri path.join(@URI_PREFIX, @appName, "/search"), params
  header['Authorization'] = Signature.generateAuthorization @GET_HTTP_METHOD, uri, header
  url = urlUtil.resolve @apiURL, uri

  @apiCall url, @GET_HTTP_METHOD, header, null, callback
  return

# 搜索文档 https://help.aliyun.com/document_detail/57155.html
# @param {String|Object} query 搜索参数（包含各子参数）必须
#       Object: config:{String|Object}
#               query: {String} 必须
#               filter: {String} 数据过滤的搜索子句参数
#               sort: {String}  数据排序的搜索子句参数
#               aggregate: {String} 统计子句参数
#               distinct: {String}  聚合子句参数
# @param {String|Array} fields 指定返回的字段，英文;符号分割 可以为Null(为Null,只返回主键数据)
# @param {String} qp 指定要使用的查询分析规则，多个规则使用英文逗号（,）分隔
# @param {String} disable 关闭指定已生效的参数功能，目前仅支持禁用 qp，summary，first_rank，second_rank 等参数功能
# @param {String} first_rank_name 设置粗排表达式名字
# @param {String} second_rank_name 设置精排表达式名字
# @param {Object|String} summary 飘红设置参数 https://help.aliyun.com/document_detail/57155.html
# @return callback(err, data)
#   data(json格式)  成功：'{"status":"OK","result":{"searchtime":0.008163,"total":3,"num":3,"viewtotal":3,"items":[{"id":"bbbbbb","title":"zhe li shi yi ge biao ti 003","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"ccccccc","title":"zhe li shi yi ge biao ti 005","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"},{"id":"aaaaaaaa","title":"zhe li shi yi ge biao ti 002","owner_id":"GO2SIsP","desc":"这里是文档的详细内容","model_name":"iconpack","index_name":"test"}],"facet":[]},"errors":[],"tracer":""}'
#         失败：'{"status":"FAIL","errors":[{"code":4010,"message":"timestamp expired"}],"RequestId":"141344839303112480055370"}'
advancedSearch = (query, fields, summary, qp, disable, first_rank_name, second_rank_name, callback) ->
  query = Tools.makeQuery(query, @pageSize)
  return callback('missing query') unless query?
  params = {}
  fields = Tools.makeFields(fields)
  params['fetch_fields'] = fields if fields?
  params['query'] = query
  params['qp'] = qp if qp?
  params['disable'] = disable if disable?
  params['first_rank_name'] = first_rank_name if first_rank_name?
  params['second_rank_name'] = second_rank_name if second_rank_name?
  params['summary'] = Tools.makeSummary(summary) if summary?
  header = Tools.generateHeader()
  #header['Content-MD5'] = ''
  uri = Tools.generateUri path.join(@URI_PREFIX, @appName, "/search"), params
  header['Authorization'] = Signature.generateAuthorization @GET_HTTP_METHOD, uri, header
  url = urlUtil.resolve @apiURL, uri

  @apiCall url, @GET_HTTP_METHOD, header, null, callback
  return

module.exports =
  search: search
  searchById: searchById
  searchByMultipleId: searchByMultipleId
  advancedSearch:advancedSearch
