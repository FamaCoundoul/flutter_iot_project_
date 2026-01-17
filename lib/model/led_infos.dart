class LEDInfos {
  String? status;
  bool? state;
  int? timestamp;
  String? mode;

  LEDInfos({this.status, this.state, this.timestamp, this.mode});

  LEDInfos.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    state = json['state'];
    timestamp = json['timestamp'];
    mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['state'] = this.state;
    data['timestamp'] = this.timestamp;
    data['mode'] = this.mode;
    return data;
  }
}
