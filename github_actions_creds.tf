# GitHub Actions で利用する IAM Role を定義する
# ref. https://docs.github.com/ja/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-the-identity-provider-to-aws
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# IAM Role に設定する信頼ポリシー
# 特定の aud と sub Claim を持つ GitHub Actions OIDC Provider を信頼する
# @see https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    # OIDC Provider として登録した GitHub Actions を信頼する
    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.github_actions.arn
      ]
    }
    # audience の検証
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    # GitHub Repository で制限する
    # この Condition が無い場合、sts.amazonaws.com を audience にもつ GitHub Actions からのリクエストを信頼してしまうため危険
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      // "repo:octo-org/octo-repo:*"
      // "repo:GitHubOrg/GitHubRepo:ref:refs/heads/GitHubBranch"
      values   = ["__REPLACE_TO_SUBJECT_CLAIM__"]
    }
  }
}

# codedeploy-java-cli-app リポジトリ向けの IAM ロール
resource "aws_iam_role" "github_actions_java_cli_app" {
  name = join("-", [local.name_tag, "gh-actions-java-cli-app"])
  assume_role_policy = replace(
    data.aws_iam_policy_document.github_actions.json,
    "__REPLACE_TO_SUBJECT_CLAIM__",
    "repo:kiyota-tagbangers/github-actions-playground:*"
  )
  inline_policy {
    name   = "deploy_policy"
    policy = data.aws_iam_policy_document.java_cli_app_policy.json
  }
}

# codedeploy-java-cli-app リポジトリ向けの IAM ポリシー
data "aws_iam_policy_document" "java_cli_app_policy" {
  statement {
    actions = [
      "codedeploy:Get*",
      "codedeploy:Batch*",
      "codedeploy:CreateDeployment",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:List*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "s3:putObject",
    ]
    resources = [
      "${aws_s3_bucket.app_jar.arn}/*",
      "${aws_s3_bucket.codedeploy_revision.arn}/*",
    ]
  }
}
