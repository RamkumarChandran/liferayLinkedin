package com.aimprosoft.portlet.login.social.linkedin;

import com.liferay.portal.kernel.exception.SystemException;

import javax.portlet.PortletRequest;

/**
 * @author V. Koshelenko
 */
public interface LinkedInConnect {

    public String getAppId(PortletRequest request) throws SystemException;

    public String getAppSecret(PortletRequest request) throws SystemException;

    public String getRedirectURL(PortletRequest request) throws SystemException;

    public boolean isEnabled(PortletRequest request) throws SystemException;
}

