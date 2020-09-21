```java
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.util.Sets;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.event.RefreshRoutesEvent;
import org.springframework.cloud.gateway.filter.FilterDefinition;
import org.springframework.cloud.gateway.handler.predicate.PredicateDefinition;
import org.springframework.cloud.gateway.route.RouteDefinition;
import org.springframework.cloud.gateway.route.RouteDefinitionWriter;
import org.springframework.cloud.gateway.support.NameUtils;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;


@Configuration
public class GatewayFilter implements WebFilter {
    /**
     * predicates: Header Set
     */
    private static final Set<String> headerRouteSet = Sets.newHashSet();
    /**
     * predicates: Query Set
     */
    private static final Set<String> queryRouteSet = Sets.newHashSet();

    @Autowired
    private RouteDefinitionWriter routeDefinitionWriter;

    @Autowired
    private ApplicationEventPublisher publisher;

    @Value("${spring.cloud.gateway.pathRegexp}")
    private String regexp;

    @Value("${spring.cloud.gateway.name:ServiceName}")
    private String name;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {

        HttpHeaders headers = exchange.getRequest().getHeaders();
        List<String> list = headers.get(name);
        String serviceName = exchange.getRequest().getQueryParams().getFirst(name);

        Boolean sure = list != null && list.size() > 0 ? true : false;
        if (sure) {
            serviceName = list.get(0);
            String id = StringUtils.join(serviceName, "-Header");
            if (!headerRouteSet.contains(id)) {
                CreateRoute(serviceName, "Header", id, headerRouteSet);
            }
        } else if (StringUtils.isNotBlank(serviceName) && !queryRouteSet.contains(StringUtils.join(serviceName, "-Query"))) {
            CreateRoute(serviceName, "Query", StringUtils.join(serviceName, "-Query"), queryRouteSet);
        }

        return chain.filter(exchange);
    }

    private void CreateRoute(String serviceName, String query, String id, Set<String> routeSet) {
        RouteDefinition routeDefinition = new RouteDefinition();

        routeDefinition.setId(id);
        PredicateDefinition predicateDefinition = new PredicateDefinition();
        predicateDefinition.setName(query);
        Map<String, String> predicateParams = new HashMap<>(8);
        predicateParams.put(NameUtils.generateName(0), name);
        predicateParams.put(NameUtils.generateName(1), serviceName);
        predicateDefinition.setArgs(predicateParams);

        FilterDefinition responseFilter = new FilterDefinition();
        responseFilter.setName("AddResponseHeader");
        Map<String, String> filterParams = new HashMap<>(8);
        filterParams.put(NameUtils.generateName(0), name);
        filterParams.put(NameUtils.generateName(1), serviceName);
        responseFilter.setArgs(filterParams);

        FilterDefinition rewritePathFilter = new FilterDefinition();
        rewritePathFilter.setName("RewritePath");
        Map<String, String> rewritePathParams = new HashMap<>(8);
        rewritePathParams.put(NameUtils.generateName(0), regexp);
        rewritePathParams.put(NameUtils.generateName(1), "/$\\{segment}");
        rewritePathFilter.setArgs(rewritePathParams);

        routeDefinition.setPredicates(Arrays.asList(predicateDefinition));
        routeDefinition.setFilters(Arrays.asList(responseFilter, rewritePathFilter));
        try {
            URI uri = new URI("lb://" + serviceName);
            routeDefinition.setUri(uri);
        } catch (URISyntaxException e) {
            throw new RuntimeException("网关URI异常：" + e.getMessage());
        }

        this.routeDefinitionWriter.save(Mono.just(routeDefinition)).subscribe();
        this.publisher.publishEvent(new RefreshRoutesEvent(this));
        routeSet.add(id);
    }

}

```
