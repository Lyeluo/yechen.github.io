## openfeign拦截器
适用场景：openfeign调用其他服务时需要统一添加header等参数
```java
package com.yuanian.component.schedule.filter;

import com.xxl.job.core.util.XxlJobRemotingUtil;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * @author liujy
 * @date 2020/8/21 10:57
 * 调用调度中心API时传递调度中心token
 **/
@Component
public class FeignEcsJobInterceptor implements RequestInterceptor {

    @Value("${yn.job.accessToken}")
    private String jobAccessToken;

    @Override
    public void apply(RequestTemplate template) {
        template.header(XxlJobRemotingUtil.XXL_JOB_ACCESS_TOKEN, jobAccessToken);

    }


}

```
