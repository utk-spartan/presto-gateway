package com.lyft.data.gateway.ha.router;

import javax.servlet.http.HttpServletRequest;

/** RoutingGroupSelector provides a way to match an HTTP request to a Gateway routing group. */
public interface RoutingGroupSelector {
  String PRESTO_ROUTING_GROUP_HEADER = "X-Presto-Routing-Group";
  String TRINO_ROUTING_GROUP_HEADER = "X-Trino-Routing-Group";

  /**
   * Routing group selector that relies on the X-Presto-Routing-Group header to determine the right
   * routing group.
   */
  static RoutingGroupSelector byRoutingGroupHeader() {
    return request -> getRoutingGroupHeader(request);
  }

  static String getRoutingGroupHeader(HttpServletRequest request) {
    String prestoHeader = request.getHeader(PRESTO_ROUTING_GROUP_HEADER);
    String trinoHeader = request.getHeader(TRINO_ROUTING_GROUP_HEADER);
    if (prestoHeader == null) {
      return trinoHeader;
    } else {
      return prestoHeader;
    }
  }

  /**
   * Given an HTTP request find a routing group to direct the request to. If a routing group cannot
   * be determined return null.
   */
  String findRoutingGroup(HttpServletRequest request);
}
