package com.rarestep.zendesk;

import android.content.Context;

import org.apache.cordova.*;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.List;

import zendesk.core.AnonymousIdentity;
import zendesk.core.Identity;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.guide.ViewArticleActivity;
import zendesk.support.request.RequestActivity;
import zendesk.support.request.RequestConfiguration;
import zendesk.support.requestlist.RequestListActivity;
import zendesk.configurations.Configuration;
// import com.zendesk.logger.Logger;
// import android.util.Log;

public class Zendesk extends CordovaPlugin {
  private static final String ACTION_INITIALIZE = "initialize";
  private static final String ACTION_SET_ANONYMOUS_IDENTITY = "setAnonymousIdentity";
  private static final String ACTION_SHOW_HELP_CENTER = "showHelpCenter";
  private static final String ACTION_SHOW_HELP_CENTER_ARTICLE = "showHelpCenterArticle";
  private static final String ACTION_SHOW_TICKET_REQUEST = "showTicketRequest";
  private static final String ACTION_SHOW_USER_TICKETS = "showUserTickets";
  // private static final String LOG_TAG = "ZENDESK";

  @Override
  public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext)
    throws JSONException {
    if (ACTION_INITIALIZE.equals(action)) {
      String appId = args.getString(0);
      String clientId = args.getString(1);
      String zendeskUrl = args.getString(2);

      zendesk.core.Zendesk.INSTANCE.init(this.getContext(), zendeskUrl, appId, clientId);
      Support.INSTANCE.init(zendesk.core.Zendesk.INSTANCE);
    } else if (ACTION_SET_ANONYMOUS_IDENTITY.equals(action)) {

      Identity identity = new AnonymousIdentity.Builder()
        .withNameIdentifier("user")
        .build();

      zendesk.core.Zendesk.INSTANCE.setIdentity(identity);
    } else if (ACTION_SHOW_HELP_CENTER.equals(action)) {
      String groupType = args.getString(0);
      List<Long> groupIds;
      List<String> labels;


      if (!args.isNull(1)) {
        groupIds = jsonArrayToList(args.getJSONArray(1));
      } else {
        groupIds = new ArrayList<Long>();
      }

      if (!args.isNull(2)) {
        labels = jsonArrayToList(args.getJSONArray(2));
      } else {
        labels = new ArrayList<String>();
      }

      zendesk.support.guide.HelpCenterConfiguration.Builder helpCenterActivityBuilder = HelpCenterActivity.builder();

      if ("category".equals(groupType) && !groupIds.isEmpty()) {
        helpCenterActivityBuilder = helpCenterActivityBuilder.withArticlesForCategoryIds(groupIds);
      } else if ("section".equals(groupType) && !groupIds.isEmpty()) {
        helpCenterActivityBuilder = helpCenterActivityBuilder.withArticlesForSectionIds(groupIds);
      }

      if (labels.size() > 0) {
        helpCenterActivityBuilder = helpCenterActivityBuilder.withLabelNames(labels);
      }

      Configuration requestActivityConfig = RequestActivity.builder()
        .withTags("mobile", "android")
        .config();

      helpCenterActivityBuilder.show(this.cordova.getActivity(), requestActivityConfig);
    } else if (ACTION_SHOW_HELP_CENTER_ARTICLE.equals(action)) {
      String articleId = args.getString(0);
      ViewArticleActivity.builder(Long.parseLong(articleId)).show(this.cordova.getActivity());
    } else if (ACTION_SHOW_TICKET_REQUEST.equals(action)) {
      String subject = args.getString(0);
      List<String> tags;

      if (!args.isNull(1)) {
        tags = jsonArrayToList(args.getJSONArray(1));
      } else {
        tags = new ArrayList<String>();
      }

      RequestConfiguration.Builder requestActivityBuilder = RequestActivity.builder();

      if (subject != null) {
        requestActivityBuilder = requestActivityBuilder.withRequestSubject(subject);
      }

      if (!tags.isEmpty()) {
        requestActivityBuilder = requestActivityBuilder.withTags(tags);
      }

      requestActivityBuilder.show(this.cordova.getActivity());
    } else if (ACTION_SHOW_USER_TICKETS.equals(action)) {
      RequestListActivity.builder().show(this.cordova.getActivity());
    } else {
      callbackContext.error("Invalid action: " + action);
      return false;
    }

    callbackContext.success();
    return true;
  }

  private Context getContext() {
    return this.cordova.getActivity().getApplicationContext();
  }

  private <T> List<T> jsonArrayToList(JSONArray jsonArray) {
    List<T> arrayList = new ArrayList<T>();

    for (int i = 0; i < jsonArray.length(); i++) {
      try {
        arrayList.add((T)jsonArray.get(i));
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }

    return arrayList;
  }
}
