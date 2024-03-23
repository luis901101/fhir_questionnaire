enum ResourceStatus {
  loading,
  transient,
  success,
  error,
}

extension ResourceUtils on ResourceStatus {
  bool get isLoading => this == ResourceStatus.loading;
  bool get isTransient => this == ResourceStatus.transient;
  bool get isSuccess => this == ResourceStatus.success;
  bool get isError => this == ResourceStatus.error;
}

class Resource<T> {
  ResourceStatus status;
  String? message;
  int? code;
  dynamic exception;
  dynamic extras;
  T? data;

  Resource(
      {this.status = ResourceStatus.error,
      this.data,
      this.message,
      this.code,
      this.exception,
      this.extras});

  factory Resource.success(T? data, {dynamic extras}) =>
      Resource(status: ResourceStatus.success, data: data, extras: extras);
  factory Resource.error(T? data, String? message,
          {int? code, dynamic exception, dynamic extras}) =>
      Resource(
          status: ResourceStatus.error,
          data: data,
          message: message,
          code: code,
          exception: exception,
          extras: extras);
  factory Resource.loading(T? data, {dynamic extras}) =>
      Resource(status: ResourceStatus.loading, data: data, extras: extras);

  bool exists() => data != null;

  bool get isLoading => status.isLoading;
  bool get isTransient => status.isTransient;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resource &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          message == other.message &&
          code == other.code &&
          exception == other.exception &&
          extras == other.extras &&
          data == other.data;

  @override
  int get hashCode =>
      status.hashCode ^
      message.hashCode ^
      code.hashCode ^
      exception.hashCode ^
      extras.hashCode ^
      data.hashCode;

  Resource<T> clone(
      {required Resource<T> currentData,
      Resource<T>? newData,
      bool merge = false}) {
    final clone = Resource<T>()
      ..status = newData?.status ?? currentData.status
      ..message = currentData.message
      ..code = newData?.code
      ..exception = newData?.exception ?? currentData.exception
      ..extras = newData?.extras ?? currentData.extras
      ..data = newData?.data ?? currentData.data;

    if (merge) {
      currentData.status = clone.status;
      currentData.message = clone.message;
      currentData.code = clone.code;
      currentData.exception = clone.exception;
      currentData.extras = clone.extras;
      currentData.data = clone.data;
    }

    return clone;
  }

  static bool hasData(Resource? resource) => resource?.exists() ?? false;
}
