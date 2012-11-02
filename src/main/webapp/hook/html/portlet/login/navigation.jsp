<%@ page import="com.liferay.portal.kernel.linkedin.LinkedInConnectUtil" %>
<%@ page import="com.liferay.portal.kernel.linkedin.LinkedInConnect" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="com.google.code.linkedinapi.client.LinkedInApiClient" %>
<%@ page import="com.google.code.linkedinapi.client.oauth.LinkedInAccessToken" %>
<%@ page import="com.google.code.linkedinapi.client.oauth.LinkedInRequestToken" %>
<%@ page import="com.google.code.linkedinapi.client.LinkedInApiClientFactory" %>
<%@ page import="com.google.code.linkedinapi.schema.Person" %>
<%@ page import="com.liferay.portal.util.PortletKeys" %>
<%@ page import="com.liferay.portal.kernel.twitter.TwitterConnectUtil" %>
<%@ page import="twitter4j.auth.RequestToken" %>
<%@ page import="twitter4j.Twitter" %>
<%--
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/login/init.jsp" %>

<%
String strutsAction = ParamUtil.getString(request, "struts_action");

boolean showAnonymousIcon = false;

if (!strutsAction.startsWith("/login/create_anonymous_account") && portletName.equals(PortletKeys.FAST_LOGIN)) {
	showAnonymousIcon = true;
}

boolean showCreateAccountIcon = false;

if (!strutsAction.equals("/login/create_account") && company.isStrangers() && !portletName.equals(PortletKeys.FAST_LOGIN)) {
	showCreateAccountIcon = true;
}

boolean showFacebookConnectIcon = false;

if (!strutsAction.startsWith("/login/facebook_connect") && FacebookConnectUtil.isEnabled(company.getCompanyId())) {
	showFacebookConnectIcon = true;
}

/*==== PATCH Linked In ====*/
    boolean showLinkedInIcon = false;
    if (!strutsAction.startsWith("/login/enter_email") && LinkedInConnectUtil.isEnabled(company.getCompanyId())) {
        showLinkedInIcon = true;
    }
/*===============*/

/*==== PATCH Twitter ====*/
    boolean showTwitterInIcon = false;
    if (!strutsAction.startsWith("/login/twitter") && TwitterConnectUtil.isEnabled(company.getCompanyId())) {
        showTwitterInIcon = true;
    }
/*===============*/

boolean showForgotPasswordIcon = false;

if (!strutsAction.equals("/login/forgot_password") && (company.isSendPassword() || company.isSendPasswordResetLink())) {
	showForgotPasswordIcon = true;
}

boolean showOpenIdIcon = false;

if (!strutsAction.equals("/login/open_id") && OpenIdUtil.isEnabled(company.getCompanyId())) {
	showOpenIdIcon = true;
}

boolean showSignInIcon = false;

if (Validator.isNotNull(strutsAction) && !strutsAction.equals("/login/login")) {
	showSignInIcon = true;
}
%>

<c:if test="<%= showAnonymousIcon || showCreateAccountIcon || showForgotPasswordIcon || showOpenIdIcon || showSignInIcon %>">
	<div class="navigation">
		<liferay-ui:icon-list>
			<c:if test="<%= showAnonymousIcon %>">
				<portlet:renderURL var="anonymousURL">
					<portlet:param name="struts_action" value="/login/create_anonymous_account" />
				</portlet:renderURL>

				<liferay-ui:icon
					message="guest"
					src='<%= themeDisplay.getPathThemeImages() + "/common/user_icon.png" %>'
					url="<%= anonymousURL %>"
				/>
			</c:if>

			<c:if test="<%= showSignInIcon %>">

				<%
				String signInURL = themeDisplay.getURLSignIn();

				if (portletName.equals(PortletKeys.FAST_LOGIN)) {
					signInURL = HttpUtil.addParameter(signInURL, "windowState", LiferayWindowState.POP_UP.toString());
				}
				%>

				<liferay-ui:icon
					image="status_online"
					message="sign-in"
					url="<%= signInURL %>"
				/>
			</c:if>

			<c:if test="<%= showFacebookConnectIcon %>">
				<portlet:renderURL var="loginRedirectURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
					<portlet:param name="struts_action" value="/login/login_redirect" />
				</portlet:renderURL>

				<%
				String facebookAuthRedirectURL = FacebookConnectUtil.getRedirectURL(themeDisplay.getCompanyId());
				facebookAuthRedirectURL = HttpUtil.addParameter(facebookAuthRedirectURL, "redirect", HttpUtil.encodeURL(loginRedirectURL.toString()));

				String facebookAuthURL = FacebookConnectUtil.getAuthURL(themeDisplay.getCompanyId());
				facebookAuthURL = HttpUtil.addParameter(facebookAuthURL, "client_id", FacebookConnectUtil.getAppId(themeDisplay.getCompanyId()));
				facebookAuthURL = HttpUtil.addParameter(facebookAuthURL, "redirect_uri", facebookAuthRedirectURL);
				facebookAuthURL = HttpUtil.addParameter(facebookAuthURL, "scope", "email");

				String taglibOpenFacebookConnectLoginWindow = "javascript:var facebookConnectLoginWindow = window.open('" + facebookAuthURL.toString() + "','facebook', 'align=center,directories=no,height=560,location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,width=1000'); void(''); facebookConnectLoginWindow.focus();";
				%>

				<liferay-ui:icon
					image="../social_bookmarks/facebook"
					message="facebook"
					url="<%= taglibOpenFacebookConnectLoginWindow %>"
				/>
			</c:if>

            <%-- ==== PATCH Twitter ==== --%>
            <c:if test="<%= showTwitterInIcon %>">
                <%
                    //base redirect URL
                    String twitterRedirectURL = TwitterConnectUtil.getRedirectURL(themeDisplay.getCompanyId());

                    //set URL parameters
                    twitterRedirectURL = HttpUtil.addParameter(twitterRedirectURL, "p_p_id", PortletKeys.LOGIN);
                    twitterRedirectURL = HttpUtil.addParameter(twitterRedirectURL, "p_p_state", "normal");
                    twitterRedirectURL = HttpUtil.addParameter(twitterRedirectURL, "p_p_mode", "view");

                    String twitterStrutsActionParameter = "_" + PortletKeys.LOGIN + "_struts_action";
                    String twitterStrutsActionValue = "/login/twitter";

                    twitterRedirectURL = HttpUtil.addParameter(twitterRedirectURL, twitterStrutsActionParameter, twitterStrutsActionValue);

                    Twitter twitter = TwitterConnectUtil.getTwitter(themeDisplay.getCompanyId());

                    RequestToken twitterRequestToken = TwitterConnectUtil.getTwitterRequestToken(twitter, twitterRedirectURL);

                    session.setAttribute("twitter", twitter);
                    session.setAttribute("twitterRequestToken", twitterRequestToken);

                    String twitterAuthUrl = twitterRequestToken.getAuthorizationURL();
                %>

                <portlet:renderURL var="twitterLoginRedirectURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
                    <portlet:param name="struts_action" value="/login/login_redirect" />
                </portlet:renderURL>
                <li>
                    <a href="#" onclick="window.location.href = '<%= twitterAuthUrl %>'">
                        <img src='<%= themeDisplay.getPathThemeImages() + "/twitter/twitter.jpg" %>' alt="Twitter" />
                        Twitter
                    </a>
                </li>
            </c:if>
            <%-- ========================== --%>

            <%-- ==== PATCH Linked In ==== --%>
            <c:if test="<%= showLinkedInIcon %>">
				<portlet:renderURL var="linkedInloginRedirectURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
					<portlet:param name="struts_action" value="/login/login_redirect" />
				</portlet:renderURL>
                <%

                    //base redirect URL
                    String linkedInRedirectURL = LinkedInConnectUtil.getRedirectURL(themeDisplay.getCompanyId());

                    //set URL parameters
                    linkedInRedirectURL = HttpUtil.addParameter(linkedInRedirectURL, "p_p_id", PortletKeys.LOGIN);
                    linkedInRedirectURL = HttpUtil.addParameter(linkedInRedirectURL, "p_p_state", "normal");
                    linkedInRedirectURL = HttpUtil.addParameter(linkedInRedirectURL, "p_p_mode", "view");

                    String strutsActionParameter = "_" + PortletKeys.LOGIN + "_struts_action";
                    String strutsActionValue = "/login/enter_email";

                    linkedInRedirectURL = HttpUtil.addParameter(linkedInRedirectURL, strutsActionParameter, strutsActionValue);

                    LinkedInRequestToken requestToken = LinkedInConnectUtil.getLinkedInRequestToken(themeDisplay.getCompanyId(), linkedInRedirectURL);

                    session.setAttribute("requestToken", requestToken);

                    String linkedInAuthUrl = requestToken.getAuthorizationUrl();
                %>
                <li>
                    <a href="#" onclick="window.location.href = '<%= linkedInAuthUrl %>'">
                        <img src='<%= themeDisplay.getPathThemeImages() + "/linkedin/linkedin.jpg" %>' alt="Linked In" />
                        Linked In
                    </a>
                </li>
            </c:if>
            <%-- ========================== --%>

			<c:if test="<%= showOpenIdIcon %>">
				<portlet:renderURL var="openIdURL">
					<portlet:param name="struts_action" value="/login/open_id" />
				</portlet:renderURL>

				<liferay-ui:icon
					message="open-id"
					src='<%= themeDisplay.getPathThemeImages() + "/common/openid.gif" %>'
					url="<%= openIdURL %>"
				/>
			</c:if>

			<c:if test="<%= showCreateAccountIcon %>">
				<liferay-ui:icon
					image="add_user"
					message="create-account"
					url="<%= PortalUtil.getCreateAccountURL(request, themeDisplay) %>"
				/>
			</c:if>

			<c:if test="<%= showForgotPasswordIcon %>">
				<portlet:renderURL var="forgotPasswordURL">
					<portlet:param name="struts_action" value="/login/forgot_password" />
				</portlet:renderURL>

				<liferay-ui:icon
					image="help"
					message="forgot-password"
					url="<%= forgotPasswordURL %>"
				/>
			</c:if>
		</liferay-ui:icon-list>
	</div>
</c:if>