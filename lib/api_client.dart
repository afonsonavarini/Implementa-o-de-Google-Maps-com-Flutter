///APIs class is for api tags
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'response_data.dart';

part 'api_client.g.dart';

class Apis {
  static const String endpoint = '592d0837dfb722363177';
}
@RestApi(baseUrl: "https://api.npoint.io/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET(Apis.endpoint)
  Future<ResponseData> getEndpoint();
}